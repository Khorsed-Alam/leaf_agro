"""
AgriCare AI — Training Callbacks Module.
Phase 38: AI Model Training and Fine-Tuning.

Provides production-ready, standardized Keras callbacks for two-stage transfer learning:
1. ModelCheckpoint: Saves best weights strictly on validation loss
2. EarlyStopping: Restores best weights and prevents overfitting
3. ReduceLROnPlateau: Decays learning rate dynamically when plateau is detected
4. CSVLogger: Persists epoch-by-epoch loss and accuracy metrics
5. TensorBoard: Generates visualization logs for loss curves and computational graphs
"""

from pathlib import Path
from typing import List, Optional
import tensorflow as tf

try:
    from .config import (
        EARLY_STOPPING_PATIENCE,
        REDUCE_LR_PATIENCE,
        REDUCE_LR_FACTOR,
        MIN_LR,
        TENSORBOARD_LOGS_DIR,
    )
except ImportError:
    from config import (
        EARLY_STOPPING_PATIENCE,
        REDUCE_LR_PATIENCE,
        REDUCE_LR_FACTOR,
        MIN_LR,
        TENSORBOARD_LOGS_DIR,
    )


def get_training_callbacks(
    stage_name: str,
    checkpoint_path: Path,
    log_csv_path: Path,
    tensorboard_dir: Optional[Path] = None,
    early_stopping_patience: int = EARLY_STOPPING_PATIENCE,
    reduce_lr_patience: int = REDUCE_LR_PATIENCE,
    min_lr: float = MIN_LR,
    restore_best_weights: bool = True
) -> List[tf.keras.callbacks.Callback]:
    """
    Constructs a robust suite of training callbacks for a specified training stage.

    Args:
        stage_name: Name of the stage ('stage_a' or 'stage_b').
        checkpoint_path: Destination path for best model checkpoint (.keras format).
        log_csv_path: Destination path for epoch metrics CSV log.
        tensorboard_dir: Root directory for TensorBoard logs.
        early_stopping_patience: Number of epochs with no improvement before stopping.
        reduce_lr_patience: Number of epochs with no improvement before reducing LR.
        min_lr: Lower bound on learning rate decay.
        restore_best_weights: Whether EarlyStopping restores best weights upon stopping.

    Returns:
        List of configured Keras callback instances.
    """
    checkpoint_path = Path(checkpoint_path)
    checkpoint_path.parent.mkdir(parents=True, exist_ok=True)

    log_csv_path = Path(log_csv_path)
    log_csv_path.parent.mkdir(parents=True, exist_ok=True)

    callbacks: List[tf.keras.callbacks.Callback] = []

    # 1. Model Checkpoint (Monitors validation loss strictly)
    checkpoint_cb = tf.keras.callbacks.ModelCheckpoint(
        filepath=str(checkpoint_path),
        monitor="val_loss",
        save_best_only=True,
        mode="min",
        verbose=1
    )
    callbacks.append(checkpoint_cb)

    # 2. Early Stopping (Restores best weights to guarantee optimal state)
    early_stopping_cb = tf.keras.callbacks.EarlyStopping(
        monitor="val_loss",
        patience=early_stopping_patience,
        restore_best_weights=restore_best_weights,
        mode="min",
        verbose=1
    )
    callbacks.append(early_stopping_cb)

    # 3. Reduce Learning Rate on Plateau
    reduce_lr_cb = tf.keras.callbacks.ReduceLROnPlateau(
        monitor="val_loss",
        factor=REDUCE_LR_FACTOR,
        patience=reduce_lr_patience,
        min_lr=min_lr,
        mode="min",
        verbose=1
    )
    callbacks.append(reduce_lr_cb)

    # 4. CSV Logger (Persists epoch logs)
    csv_logger_cb = tf.keras.callbacks.CSVLogger(
        filename=str(log_csv_path),
        separator=",",
        append=False
    )
    callbacks.append(csv_logger_cb)

    # 5. TensorBoard Logger
    tb_root = Path(tensorboard_dir) if tensorboard_dir else TENSORBOARD_LOGS_DIR
    stage_tb_dir = tb_root / stage_name
    stage_tb_dir.mkdir(parents=True, exist_ok=True)
    tb_cb = tf.keras.callbacks.TensorBoard(
        log_dir=str(stage_tb_dir),
        histogram_freq=0,
        write_graph=True
    )
    callbacks.append(tb_cb)

    return callbacks

