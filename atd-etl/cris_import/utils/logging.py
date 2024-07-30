import logging
import sys

LOGGER_NAME = "cris_import"


def get_logger():
    """Returns the logger instance that was iniatilized via init_logger"""
    return logging.getLogger(LOGGER_NAME)


def init_logger(debug=False):
    """Initialize and return a logger that streams to STDOUT. Call this once in the main script"""
    level = logging.DEBUG if debug else logging.INFO
    logger = logging.getLogger(LOGGER_NAME)
    handler = logging.StreamHandler(stream=sys.stdout)
    formatter = logging.Formatter(fmt="%(levelname)s: %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(level)
    return logger
