LOCAL_EXTRACTS_DIR = "extracts"

"""This is the bbox used to crop the crash diagram"""
DIAGRAM_BBOX_PIXELS = {
    "old": (2589, 3531, 5001, 6048),
    "new": (2496, 3036, 4836, 5464),
}

"""If all four of these pixels are black, it is a 'new' CR3 pdf"""
NEW_CR3_FORM_TEST_PIXELS = [
    (215, 2567),
    (872, 2568),
    (625, 1806),
    (4834, 279),
]

CSV_UPLOAD_BATCH_SIZE = 1000
