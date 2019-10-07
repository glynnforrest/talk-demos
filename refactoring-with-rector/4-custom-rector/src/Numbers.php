<?php

namespace App;

final class Numbers
{
    public function getNumbers(): iterable
    {
        yield 30;
        yield 100;
        yield 40 * 8;
        yield 18 - (24 * 3);
        yield 2000 + 4 - 9;
    }
}
