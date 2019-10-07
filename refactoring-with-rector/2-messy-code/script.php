<?php

function way_too_nested(int $number) {
    if ($number > 3) {
        if ($number > 5) {
            return true;
        } else {
            if ($number < 2) {
                return true;
            }
            if ($number > 5) {
                return true;
            }
        }
        return false;
    }
    return false;
}
