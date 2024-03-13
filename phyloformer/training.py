"""The training submodule contains necessary functions to train a Phyloformer network
"""
import os
import copy
import math
from contextlib import nullcontext
from time import time
from typing import Any, Dict, Optional, Tuple, Union

import numpy as np
import torch
from torch.cuda.amp import GradScaler, autocast
from torch.utils.data import DataLoader
from tqdm import tqdm

from phyloformer.metrics import MAE, MRE
from phyloformer.phyloformer import AttentionNet
import math

Scheduler = Union[
    torch.optim.lr_scheduler._LRScheduler, torch.optim.lr_scheduler.ReduceLROnPlateau
]

LOSSES = {
    "L1": torch.nn.L1Loss(),
    "L2": torch.nn.MSELoss(),
}

OPTIMIZERS = {
    "Adam": torch.optim.Adam,
    "AdamW": torch.optim.AdamW,
    "SGD": torch.optim.SGD,
}


def init_training(
    model: AttentionNet,
    optimizer: str = "Adam",
    learning_rate: float = 1e-5,
    loss: str = "L2",
    warmup: bool = False,
    warmup_steps: int = 20,
    **kwargs,
) -> Tuple[torch.optim.Optimizer, Scheduler, torch.nn.modules.loss._Loss,]:
    """Creates and returns an optimizer, learning rate scheduler and loss function
    from a config dict

    Parameters
    ----------
    model : AttentionNet
        Phyloformer model to train
    optimizer : str, optional
        Optimization algorithm ("Adam", "AdamW", or "SGD"), by default "Adam"
    learning_rate : float, optional
        Learning rate to apply, by default 1e-5
    loss : str, optional
        Loss function (choices "L1" or "L2"), by default "L2"
    warmup : bool, optional
        Wether to do learning rate warmupt, by default False
    warmup_steps : int, optional
        Number of warmup steps, by default 20

    Returns
    -------
    Tuple[torch.optim.Optimizer,Scheduler,torch.nn.modules.loss._Loss]
        A tuple containing:
         - The optimizer
         - The learning rate scheduler
         - The loss function
    """
    optimizer_instance = _init_optimizer(
        model=model, algorithm=optimizer, learning_rate=learning_rate
    )
    scheduler = _init_scheduler(
        optimizer=optimizer_instance, warmup=warmup, warmup_steps=warmup_steps
    )
    criterion = _init_loss(loss=loss.upper())

    return optimizer_instance, scheduler, criterion


def training_loop(
    model: AttentionNet,
    optimizer: torch.optim.Optimizer,
    scheduler: Scheduler,
    criterion: torch.nn.modules.loss._Loss,
    train_data: DataLoader,
    val_data: DataLoader,
    device: str = "cpu",
    epochs: int = 80,
    amp: bool = True,
    clip_gradients: bool = True,
    early_stopping: bool = False,
    stopping_steps: int = 8,
    best_path: Optional[str] = None,
    checkpoint_path: Optional[str] = None,
    log_file: Optional[str] = None,
    tensorboard_writer: Optional[Any] = None,
    config: Dict[str, Any] = dict(),
    **kwargs,
) -> Tuple[AttentionNet, int]:
    """Trains a Phyloformer model

    Parameters
    ----------
    model : AttentionNet
        model instance to train
    optimizer : torch.optim.Optimizer
        Optimizer for training
    scheduler : Scheduler
        Learning rate scheduler
    criterion : torch.nn.modules.loss._Loss
        Loss function
    train_data : DataLoader
        Training data
    val_data : DataLoader
        Validation data
    device : str, optional
        Device on which to train ("cpu" or "cuda"), by default "cpu"
    epochs : int, optional
        Number of epochs to train the model for, by default 80
    amp : bool, optional
        Use automatic mixed precision (only available on "cuda" device), by default True
    clip_gradients : bool, optional
        Wether to clip gradients during training, by default True
    early_stopping : bool, optional
        Wether to stop trainig early if there is no improvement of validation loss
        , by default False
    stopping_steps : int, optional
        After how many stesp without improvement to stop training early, by default 8
    best_path : Optional[str], optional
        Path to save the best checkpoint so fat, by default None
    checkpoint_path : Optional[str], optional
        Path to save the last checkpoint, by default None
    log_file : Optional[str], optional
        Path to the log file to write training metrics, by default None
    tensorboard_writer : Optional[Any], optional
        SummaryWriter for following training on tensorboard, by default None
    config : Dict[str, Any], optional
        Config dictionary (saved in checkpoints), by default dict()

    Returns
    -------
    Tuple[AttentionNet, int]
        a tuple containing:
         - The model with the best validation loss
         - The epoch at which this function returns
    """

    # NHANLT - Debug
    #torch.autograd.set_detect_anomaly(True)
    if amp:
        print("With amp")
    else:
        print("Without amp")

    losses_file = None
    if log_file is not None:
        losses_file = open(log_file, "w+")
        losses_file.write("timestamp,epoch,train_loss,val_loss,val_MAE,val_MRE\n")
        losses_file.close()

    if device == "cuda":
        scaler = GradScaler()
        #scaler = GradScaler(enabled=False)
        #torch.cuda.amp.autocast(enabled=False)

    no_improvement_counter = 0
    best_model = copy.deepcopy(model)
    best_loss = None
    if device == "cuda":
        if torch.cuda.device_count() > 1:
            print("Using ", torch.cuda.device_count(), " GPUs")
            model = torch.nn.DataParallel(model)
        else:
            print("Using a single GPU")
    model = model.to(device)
    train_losses, val_losses = [], []
    val_MAEs, val_MREs = [], []

    # NHANLT - DEBUG
    #MAX_VAL = 1e30
    #x_min = MAX_VAL
    #y_min = MAX_VAL
    #output_min = MAX_VAL
    #x_max = -MAX_VAL
    #y_max = -MAX_VAL
    #output_max = -MAX_VAL

    for epoch in tqdm(range(epochs)):
        # TRAINING STEP
        model.train()
        epoch_train_losses = []
        for batch in train_data:
            x_train, y_train = batch
            #x_train, y_train = x_train.to(device), y_train.to(device)
            y_train = y_train.to(device)
            inputs = x_train.float()
            inputs = inputs.to(device)

            #print("x_train size: ", x_train.size(), "; inputs size: ", inputs.size())
            #print("x_train[0] size: ", x_train[0].size(), "; inputs[0] size: ", inputs[0].size())
            #print(x_train[0])

            #print("inputs")
            #print(inputs[0])


            with (autocast() if device == "cuda" and amp else nullcontext()):
                optimizer.zero_grad()
                outputs, _ = model(inputs)
                #print("Outside: Input size: ", inputs.size(), " on device ", inputs.get_device(), "; Output size: ", outputs.size(), " on device ", outputs.get_device())
                # NHANLT
                # Debug
                #print("Data \t Device")
                #print("x_train \t ", x_train.get_device())
                #print("y_train \t ", y_train.get_device())
                #print("inputs \t ", inputs.get_device())
                #print("outputs \t ", outputs.get_device())
                # NHANLT - Debug
                if torch.any(inputs.isnan()):
                    print("inputs is NaN")
                    print(inputs)
                    exit(1)
                if torch.any(outputs.isnan()):
                    print("outputs is NaN")
                    print(outputs)
                    exit(1)
                if torch.any(y_train.isnan()):
                    print("y_train is NaN")
                    print(y_train)
                    exit(1)

                # NHANLT - Debug
                #x_min_tmp = torch.min(inputs)
                #if x_min > x_min_tmp:
                #    x_min = x_min_tmp
                #x_max_tmp = torch.max(inputs)
                #if x_max < x_max_tmp:
                #    x_max = x_max_tmp

                #y_min_tmp = torch.min(y_train)
                #if y_min > y_min_tmp:
                #    y_min = y_min_tmp
                #y_max_tmp = torch.max(y_train)
                #if y_max < y_max_tmp:
                #    y_max = y_max_tmp

                #output_min_tmp = torch.min(outputs)
                #if output_min > output_min_tmp:
                #    output_min = output_min_tmp
                #output_max_tmp = torch.max(outputs)
                #if output_max < output_max_tmp:
                #    output_max = output_max_tmp

                # NHANLT - Debug
                #print("x (min - max): " + str(x_min) + " - " + str(x_max))
                #print("y (min - max): " + str(y_min) + " - " + str(y_max))
                #print("output (min - max): " + str(output_min) + " - " + str(output_max))

                y_train = torch.squeeze(y_train.type_as(outputs))
                train_loss = criterion(outputs, y_train)
                if torch.any(train_loss.isnan()):
                    print("train_loss is NaN")
                    print(train_loss)
                    print("inputs")
                    print(inputs)
                    print("outputs")
                    print(outputs)
                    print("y_train")
                    print(y_train)
                if device == "cuda" and amp:
                    if not torch.any(train_loss.isnan()):
                        print("train_loss is NOT NaN")
                    scaler.scale(train_loss).backward()
                    if clip_gradients:
                        print("clip_gradients")
                        scaler.unscale_(optimizer)
                        torch.nn.utils.clip_grad_norm_(
                            model.parameters(), max_norm=2, error_if_nonfinite=False
                        )
                    scaler.step(optimizer)
                    scaler.update()
                else:
                    train_loss.backward()
                    optimizer.step()

            epoch_train_losses.append(train_loss.item())

        train_losses.append(np.mean(epoch_train_losses))

        # Validation Step
        with torch.no_grad():
            epoch_MAEs, epoch_MREs, epoch_val_losses = [], [], []
            for batch in val_data:
                x_val, y_val = batch
                #x_val, y_val = x_val.to(device), y_val.to(device)
                y_val = y_val.to(device)

                model.eval()
                inputs = x_val.float()
                inputs = inputs.to(device)
                with (autocast() if device == "cuda" and amp else nullcontext()):
                    outputs, _ = model(inputs)
                    #print("Validate. inputs size: ", inputs.size(), " on device ", inputs.get_device(), ". outputs size: ", outputs.size(), " on device ", outputs.get_device(), ". y_val size: ", y_val.size(), " on device ", y_val.get_device())
                    # NHANLT
                    # Debug
                    # print("Data \t Device")
                    # print("x_val \t ", x_val.get_device())
                    # print("y_val \t ", y_val.get_device())
                    # print("inputs \t ", inputs.get_device())
                    # print("outputs \t ", outputs.get_device())
                    y_val = torch.squeeze(y_val.type_as(outputs))
                    val_loss = criterion(outputs, y_val).item()
                    val_MAE = MAE(outputs, y_val)
                    val_MRE = MRE(outputs, y_val)

                epoch_val_losses.append(val_loss)
                epoch_MAEs.append(val_MAE)
                epoch_MREs.append(val_MRE)

        val_losses.append(np.mean(epoch_val_losses))
        val_MAEs.append(np.mean(epoch_MAEs))
        val_MREs.append(np.mean(epoch_MREs))

        scheduler.step(val_losses[-1])

        # Logging
        if losses_file is not None:
            losses_file = open(log_file, "a")
            losses_file.write(
                f"{time()},{epoch},{train_losses[-1]},{val_losses[-1]},{val_MAEs[-1]},{val_MREs[-1]}\n"
            )
            losses_file.close()
        if tensorboard_writer is not None:
            tensorboard_writer.add_scalars(
                "Losses", {"train": train_losses[-1], "val": val_losses[-1]}, epoch
            )
            tensorboard_writer.add_scalar("val/MAE", val_MAEs[-1], epoch)
            tensorboard_writer.add_scalar("val/MRE", val_MREs[-1], epoch)

        if epoch == 0:
            best_loss = val_losses[-1]

        # Save checkpoint
        if checkpoint_path is not None:
            save_checkpoint(model, optimizer, scheduler, config, checkpoint_path)

        # Check if best model so far
        if epoch > 0 and val_losses[-1] < best_loss:
            no_improvement_counter = 0
            best_loss = val_losses[-1]
            best_model = copy.deepcopy(model)
            # NHANLT
            # write the best model
            if isinstance(best_model, torch.nn.DataParallel):
                best_model.module.save(best_path + ".best_model.pt")
            else:
                best_model.save(best_path + ".best_model.pt")
            if best_path is not None:
                save_checkpoint(model, optimizer, scheduler, config, best_path)
        else:
            no_improvement_counter += 1

        # Stop early if validation loss has not improved for a while
        if (early_stopping and no_improvement_counter > stopping_steps) or math.isnan(
            val_losses[-1]
        ):
            return best_model, epoch + 1

    if losses_file is not None:
        losses_file.close()

    return best_model, epochs


def save_checkpoint(
    model: AttentionNet,
    optimizer: torch.optim.Optimizer,
    scheduler: Scheduler,
    config: Dict[str, Any],
    path: str,
):
    """Saves a checkpoint of the current training process

    Parameters
    ----------
    model : AttentionNet
        Model to save
    optimizer : torch.optim.Optimizer
        Optimizer to save
    scheduler : Scheduler
        Learning rate scheduler to save
    config : Dict[str, Any]
        Config with which training was started
    path : str
        Path to save the checkpoint to
    """
    if isinstance(model, torch.nn.DataParallel):
        tmp_model = model.module
    else:
        tmp_model = model

    checkpoint = {
        "model": {
            "architecture": tmp_model._get_architecture(),
            "state_dict": tmp_model.state_dict(),
        },
        "optimizer": optimizer.state_dict(),
        "scheduler": scheduler.state_dict(),
        "config": config,
    }

    torch.save(checkpoint, path)


def load_checkpoint(
    path: str,
    device: str = "cpu",
) -> Tuple[
    AttentionNet,
    torch.optim.Optimizer,
    Scheduler,
    torch.nn.modules.loss._Loss,
    Dict[str, Any],
]:
    """Loads a model training checkpoint from disk

    Parameters
    ----------
    path : str
        Path to the saved checkpoint
    device: str, optional
        Device to load the model onto ("cpu" or "cuda"), by default "cpu"

    Returns
    -------
    Tuple[\
    AttentionNet, torch.optim.Optimizer, Scheduler, \
    torch.nn.modules.loss._Loss, Dict[str, Any]]
        A tuple containing:
         - The model
         - The optimizer
         - The learning rate scheduler
         - The loss function
         - The training configuration
    """

    checkpoint = torch.load(path, map_location=device)
    config = checkpoint["config"]

    # Loading model
    model = AttentionNet(**checkpoint["model"]["architecture"], device=device)
    model.load_state_dict(checkpoint["model"]["state_dict"], strict=True)
    model.to(device)

    # Loading other objects
    optimizer, scheduler, loss = init_training(model, **config)
    optimizer.load_state_dict(checkpoint["optimizer"])
    scheduler.load_state_dict(checkpoint["scheduler"])

    return model, optimizer, scheduler, loss, config


def _init_optimizer(
    algorithm: str, model: AttentionNet, learning_rate: float
) -> torch.optim.Optimizer:
    """Instanciates the optimizer to train a Phyloformer model

    Parameters
    ----------
    algorithm : str
        Which optimization algorithm to use ('Adam', 'AdamW', or 'SGD')
    model : AttentionNet
        Phyloformer model you want to train
    learning_rate : float
        Learning rate to apply

    Returns
    -------
    torch.optim.Optimizer
        Optimizer to use in model training

    Raises
    ------
    ValueError
        If the specified optimization algorithm is not in the available options
    """
    if algorithm not in OPTIMIZERS:
        raise ValueError(
            f"The optimizer algorithm must be one of the following: {OPTIMIZERS.keys()}"
        )

    return OPTIMIZERS[algorithm](model.parameters(), lr=learning_rate)


def _init_scheduler(
    optimizer: torch.optim.Optimizer, warmup: bool, warmup_steps: int
) -> Scheduler:
    """Instanciates a learning rate scheduler for Phyloformer model training

    Parameters
    ----------
    optimizer : torch.optim.Optimizer
        The optimizer that will be used during training
    warmup : bool
        Wether to do a learning rate warmup
    warmup_steps : int
        Number of warmup steps

    Returns
    -------
    Scheduler
        The learning rate scheduler instance
    """
    if warmup:
        print("Warmup is not implemented yet, instanciating LR-Plateau scheduler")
    return torch.optim.lr_scheduler.ReduceLROnPlateau(
        optimizer, factor=0.5, patience=5, verbose=True
    )


def _init_loss(loss: str) -> torch.nn.modules.loss._Loss:
    """Instanciates a loss function object

    Parameters
    ----------
    loss : str
        The name of the loss function to use ("L1" or "L2")

    Returns
    -------
    torch.nn.modules.loss._Loss
        The loss function that will be used during training

    Raises
    ------
    ValueError
        If the specified loss is not available
    """
    if loss not in LOSSES:
        raise ValueError(
            f"The loss function must be one of the following: {LOSSES.keys()}"
        )
    return LOSSES[loss]
