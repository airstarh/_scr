<!doctype html>
<main>
<?php
final class Example
{
    public function run(array $items): string
    {
        if ($items[0] > 0) {
            return strtoupper("active");
        }

        return "inactive";
    }
}
?>
</main>
