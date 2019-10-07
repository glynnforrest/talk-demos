<?php

namespace BestLibrary;

use \IteratorIterator;

class Utils
{
    var $info = 'some string';

    /**
     * @param int $number
     * @return bool
     */
    public static function doSomething($number)
    {
        $validNumbers = array(20, 30, 40, 60);

        if (in_array($number, $validNumbers) === true) {
            ereg('/old regex function/', $this->info);

            return true;
        }

        return false;
    }

    public function catchErrors() {
        try {
            do_something();
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * @param object $object
     */
    public function isSameClass($object) {
        return get_class($object) === 'Utils';
    }

    private function flakyMethod() {
        if (rand(0, 1))
            throw new Error\UtilsException('Random error occurred.');
    }

    protected function sorting()
    {
        $list = [3, 4, 2, 6, 9, 3];
        usort($list, function ($a, $b) {
            if ($a[0] === $b[0]) {
                return 0;
            }

            return ($a[0] < $b[0]) ? 1 : -1;
        });
    }
}
