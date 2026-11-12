import tensorflow as tf
from pathlib import Path
try:
    from .config import IMG_SIZE, BATCH_SIZE
    from .augmentation import get_augmentation_layer
except ImportError:
    from config import IMG_SIZE, BATCH_SIZE
    from augmentation import get_augmentation_layer


def load_datasets(train_dir, val_dir, test_dir=None, batch_size=BATCH_SIZE, img_size=IMG_SIZE):
    """
    Loads training, validation, and test datasets as tf.data.Dataset streams.
    """
    train_ds = tf.keras.utils.image_dataset_from_directory(
        train_dir,
        labels="categorical",
        image_size=img_size,
        batch_size=batch_size,
        shuffle=True,
        seed=42
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        val_dir,
        labels="categorical",
        image_size=img_size,
        batch_size=batch_size,
        shuffle=False
    )

    test_ds = None
    if test_dir and Path(test_dir).exists():
        test_ds = tf.keras.utils.image_dataset_from_directory(
            test_dir,
            labels="categorical",
            image_size=img_size,
            batch_size=batch_size,
            shuffle=False
        )

    class_names = train_ds.class_names

    # Performance optimization: prefetch & cache
    aug_layer = get_augmentation_layer()
    train_ds = train_ds.map(lambda x, y: (aug_layer(x, training=True), y), num_parallel_calls=tf.data.AUTOTUNE)
    train_ds = train_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

    val_ds = val_ds.prefetch(buffer_size=tf.data.AUTOTUNE)
    if test_ds:
        test_ds = test_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

    return train_ds, val_ds, test_ds, class_names

