<?php

namespace App\CustomRector;

use PhpParser\Node;
use Rector\Rector\AbstractRector;
use Rector\RectorDefinition\CodeSample;
use Rector\RectorDefinition\RectorDefinition;
use PhpParser\Node\Scalar\LNumber;

final class IntegerToPrimeFactorsRector extends AbstractRector
{
    public function getDefinition(): RectorDefinition
    {
        return new RectorDefinition('Replace integers with their prime factors', [
            new CodeSample('return 45;', 'return (3 * 3 * 5);'),
        ]);
    }

    public function getNodeTypes(): array
    {
        return [LNumber::class];
    }

    public function refactor(Node $node): ?Node
    {
        if ($this->isPrime($node->value)) {
            return null;
        }

        $node->value = '('.implode($this->primeFactors($node->value), ' * ').')';

        return $node;
    }

    private function isPrime(int $number): bool
    {
        if ($number <= 3) {
            return true;
        }

        $max = floor(sqrt($number));
        for ($i = 2; $i <= $max; ++$i) {
            if ($number % $i === 0) {
                return false;
            }
        }

        return true;
    }

    private function primeFactors(int $number): array
    {
        if ($number <= 3) {
            return [$number];
        }

        $factors = [];
        while ($number > 1) {
            for ($i = 2; $i < $number && $number % $i; ++$i) {
            }
            $number /= $i;
            $factors[] = $i;
        }

        return $factors;
    }
}
