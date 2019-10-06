<?php

namespace Project;

use Randomizer;

class TestExtension extends \Twig_Extension
{
    private $randomizer;

    public function __construct(Randomizer $randomizer)
    {
        $this->randomizer = $randomizer;
    }

    public function getFunctions()
    {
        return [
            new \Twig_SimpleFunction('rot13', 'rot13'),
            new \Twig_SimpleFunction('random_thing', [$this->randomizer, 'generate']),
        ];
    }

    public function getFilters()
    {
        return [
            new \Twig_SimpleFilter('year', [$this, 'formatYear']),
        ];
    }

    private function formatYear(\DateTimeInterface $date)
    {
        return $date->format('Y');
    }
}
