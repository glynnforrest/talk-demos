<?php

namespace Project;

final class Randomizer
{
    public function generate()
    {
        return base64_encode(random_bytes(30));
    }
}
