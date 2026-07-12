public static function toObject($v): object
    {
        // empty() для null, '', [], false, 0 и т.п.
        if ($v === null || $v === '') {
            return new stdClass();
        }

        if (is_object($v)) {
            return $v;
        }

        if (is_array($v)) {
            $tmp = json_decode(json_encode($v), false);

            if (is_array($tmp)) {
                $obj = new stdClass();

                foreach ($tmp as $key => $value) {
                    $obj->{$key} = $value;
                }

                return $obj;
            }

            $res        = new stdClass();
            $res->value = $v;

            return $res;
        }

        if (is_string($v)) {
            $decoded = null;

            if (static::isStringValidJson($v, $decoded)) {
                return static::toObject($decoded);
            }
        }

        $res        = new stdClass();
        $res->value = $v;

        return $res;
    }