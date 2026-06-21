<?php

namespace alina\mvc\Model;

use alina\AppExceptionValidation;
use alina\GlobalRequestStorage;
use alina\Message;
use alina\Utils\Arr;
use alina\Utils\Data;
use alina\Utils\Request;
use alina\vendorExtend\illuminate\alinaLaravelCapsuleLoader as Loader;
use ErrorException;
use Exception;
use Illuminate\Database\Capsule\Manager as Dal;
use Illuminate\Database\Query\Builder as BuilderAlias;
use stdClass;

class _BaseAlinaModel
{
    #region STATES / MODES
    public static $flagDbAvailable = false;
    public const MODE_SELECT = 'SELECT';
    public const MODE_INSERT = 'INSERT';
    public const MODE_UPDATE = 'UPDATE';
    public const MODE_DELETE = 'DELETE';
    #endregion

    #region Required
    public $table;
    public $alias = '';
    public $pkName = 'id';
    public $id = null;
    protected stdClass $opts;
    public $dataArrayIdentity;
    #endregion

    #region Request
    /** @var BuilderAlias $q */
    public $q;
    public $o_GET = null;
    public $apiOperators = [
        'llt_'    => '<',
        'ggt_'    => '>',
        'eq_'     => '=',
        'lk_'     => 'LIKE',
        'notlk_'  => 'NOT LIKE',
        'noteq_'  => '!=',
        'emp_'    => 'IS NULL',
        'notemp_' => 'IS NOT NULL',
    ];
    #endregion

    #region Response
    /** @var stdClass */
    public $attributes;
    public $collection = [];
    public $state_ROWS_TOTAL = -1;
    public $pagesTotal = 0;
    #endregion

    #region Flags
    private $mode = self::MODE_SELECT;
    public $state_DATA_FILTERED = false;
    public $state_DATA_VALIDATED = false;
    public $state_AFFECTED_ROWS = null;
    public $state_EXCLUDE_COUNT_REQUEST = false;
    public $matchedUniqueFields = [];
    public $matchedConditions = [];
    public $addAuditInfo = false;
    public $flagAuditInfoLog = false;
    public $state_APPLY_GET_PARAMS = false;
    #endregion

    #region Search Parameters
    public $sortDefault = [];
    public $sortName = null;
    public $sortAsc = 'ASC';
    public $pageCurrentNumber = 0;
    public $pageSize = 500;
    #endregion

    #region Constructor
    public function __construct($opts = null)
    {
        Loader::init();
        $this->opts = new stdClass();
        $this->attributes = new stdClass();
        $this->setPkValue(null);

        if ($opts) {
            $opts = Data::toObject($opts);
            Data::mergeObjects($this->opts, $opts);
            $this->opts = $opts;
            $this->table = $opts->table ?? $this->table;
        }
        $this->alias = $this->table;
        $this->buildDefaultData();
    }
    #endregion

    #region SELECT
    public function getById($id)
    {
        return $this->getOne([$this->pkName => $id]);
    }

    public function getOne($conditions = [])
    {
        $this->state_EXCLUDE_COUNT_REQUEST = true;
        $data = $this->q()->where($conditions)->first();
        $this->attributes = Data::mergeObjects($this->attributes, $data ?: new stdClass());
        if (isset($this->attributes->{$this->pkName})) {
            $this->setPkValue($this->attributes->{$this->pkName});
        }
        $this->state_EXCLUDE_COUNT_REQUEST = false;
        return $this->attributes;
    }

    public function getAll($conditions = [], $backendSortArray = null, $limit = null, $offset = null)
    {
        $q = $this->q()->where($conditions);
        if ($limit) $q->take($limit);
        if ($offset) $q->skip($offset);
        $this->collection = $q->get();
        return $this->collection;
    }

    public function getModelByUniqueKeys($data, $uniqueKeys = null)
    {
        $data = Data::toObject($data);
        $uniqueKeys = $uniqueKeys ?: $this->uniqueKeys();

        foreach ($uniqueKeys as $fields) {
            if (!is_array($fields)) {
                throw new ErrorException('Unique fields must be array');
            }

            $conditions = [];
            $matchedFields = [];

            foreach ($fields as $field) {
                if (!property_exists($data, $field)) continue 2;
                $conditions[$field] = $data->{$field};
                $matchedFields[] = $field;
            }

            if (empty($conditions)) return false;

            $m = new static(['table' => $this->table]);
            $q = $m->q()->where($conditions);

            if (property_exists($data, $this->pkName) && $data->{$this->pkName}) {
                $q->where($this->pkName, '!=', $data->{$this->pkName});
            }

            if ($m->tableHasField('is_deleted')) {
                $q->where('is_deleted', '!=', 1);
            }

            if ($record = $q->first()) {
                $this->matchedUniqueFields = $matchedFields;
                $this->matchedConditions = $conditions;
                $this->attributes = $record;
                $this->setPkValue($record->{$this->pkName});
                return $record;
            }
        }

        return false;
    }

    #region Get With References
    public function getAllWithReferencesPart1($conditions = [], $alias = null)
    {
        $q = $this->q($alias);
        $q->select(["{$this->alias}.*"]);
        $q->where($conditions);

        if ($this->state_APPLY_GET_PARAMS) {
            $this->apiUnpackGetParams();
            $this->qApplyGetSearchParams();
        }

        $this->qJoinHasOne();

        if (method_exists($this, 'hookGetWithReferences')) {
            $this->hookGetWithReferences($q);
        }

        return $q;
    }

    public function getAllWithReferencesPart2($backendSortArray = null, $pageSize = null, $pageCurrentNumber = null, $paginationVersa = false)
    {
        $q = $this->q;

        $this->state_ROWS_TOTAL = $this->state_EXCLUDE_COUNT_REQUEST ? 1 : $q->count();
        $this->state_EXCLUDE_COUNT_REQUEST = false;

        $this->qApiOrder($backendSortArray);
        $this->qApiLimitOffset($pageSize, $pageCurrentNumber, $paginationVersa);

        $this->collection = $q->get();
        $this->joinHasMany();

        return $this->collection;
    }

    public function getAllWithReferences($conditions = [], $backendSortArray = null, $pageSize = null, $pageCurrentNumber = null, $paginationVersa = false)
    {
        $this->getAllWithReferencesPart1($conditions);
        return $this->getAllWithReferencesPart2($backendSortArray, $pageSize, $pageCurrentNumber, $paginationVersa);
    }

    public function getOneWithReferencesById($id)
    {
        return $this->getOneWithReferences([["{$this->alias}.{$this->pkName}", '=', $id]]);
    }

    public function getOneWithReferences($conditions = [])
    {
        $this->state_EXCLUDE_COUNT_REQUEST = true;
        $attributes = $this->getAllWithReferences($conditions, [], 1, 0)->first() ?: new stdClass();
        if (isset($attributes->{$this->pkName})) {
            $this->setPkValue($attributes->{$this->pkName});
        }
        $this->attributes = Data::mergeObjects($this->attributes, $attributes);
        return $this->attributes;
    }
    #endregion
    #endregion

    #region UPSERT
    public function upsert($data)
    {
        return $this->upsertByUniqueFields($data);
    }

    public function upsertByUniqueFields($data, ?array $uniqueKeys = null)
    {
        sprintf('ASD %s asd %s', 'aaa', 'bbb');
        $data = Data::toObject($data);
        $data = Data::mergeObjects($this->attributes, $data);

        if (!empty($data->{$this->pkName})) {
            $this->setPkValue($data->{$this->pkName});
            $this->updateById($data);
            return $this;
        }

        if ($this->getModelByUniqueKeys($data, $uniqueKeys)) {
            $this->update($data, $this->matchedConditions);
        } else {
            $this->insert($data);
        }

        return $this;
    }
    #endregion

    #region INSERT
    public function insert($data)
    {
        $this->mode = self::MODE_INSERT;
        $data = Data::toObject($data);
        $data = Data::mergeObjects($this->buildDefaultData(), $data);
        $dataArray = $this->prepareDbData($data);

        $this->callHook('hookRightBeforeSave', $dataArray);

        $id = $this->q()->insertGetId($dataArray, $this->pkName);
        $this->attributes = $data = Data::toObject($dataArray);
        $this->setPkValue($id, $data);

        GlobalRequestStorage::setPlus1('BaseModelQueries');
        $this->logAudit($data);

        $this->callHook('hookRightAfterSave', $data);
        $this->resetFlags();

        return $this->attributes;
    }
    #endregion

    #region UPDATE
    public function updateById($data, $id = null)
    {
        $data = Data::toObject($data);
        $pkValue = $id ?? $data->{$this->pkName} ?? $this->id;

        if (empty($pkValue)) {
            throw new AppExceptionValidation("Cannot UPDATE row in table {$this->table}. Primary Key is not set.");
        }

        $this->setPkValue($pkValue);
        $this->update($data, [$this->pkName => $pkValue]);
        $this->attributes = Data::mergeObjects($this->attributes, $data);
        $this->setPkValue($pkValue, $data);

        return $this->attributes;
    }

    public function update($data, $conditions = [])
    {
        $this->mode = self::MODE_UPDATE;
        $data = Data::toObject($data);
        $dataArray = $this->prepareDbData($data);

        $this->callHook('hookRightBeforeSave', $dataArray);

        $this->state_AFFECTED_ROWS = $this->q()->where($conditions)->update($dataArray);

        if ($this->state_AFFECTED_ROWS == 1) {
            $this->attributes = Data::mergeObjects($this->attributes, Data::toObject($dataArray));
            if (isset($this->attributes->{$this->pkName})) {
                $this->setPkValue($this->attributes->{$this->pkName});
            }
        }

        $this->callHook('hookRightAfterSave', $data);
        GlobalRequestStorage::setPlus1('BaseModelQueries');
        $this->logAudit([$data, $conditions]);

        $this->resetFlags();
        return $this;
    }
    #endregion

    #region DELETE
    public function delete(array $conditions)
    {
        $this->mode = self::MODE_DELETE;
        $count = $this->q()->where($conditions)->delete();

        GlobalRequestStorage::setPlus1('BaseModelQueries');
        $this->logAudit($conditions);

        $this->state_AFFECTED_ROWS = $count;
        $this->resetFlags();

        return $count;
    }

    public function deleteById($id)
    {
        $this->setPkValue($id);
        return $this->delete([$this->pkName => $id]);
    }

    public function smartDeleteById($id, $additionalData = null)
    {
        if (method_exists($this, 'bizDelete')) {
            $this->bizDelete($id);
            return true;
        }

        if ($this->tableHasField('is_deleted') || $additionalData) {
            $data = $additionalData ? Data::toObject($additionalData) : new stdClass();
            $data->is_deleted = 1;
            $data->{$this->pkName} = $id;
            $this->updateById($data);
            return true;
        }

        $this->deleteById($id);
        return true;
    }
    #endregion

    #region API, LIMIT, ORDER
    public function qApiResponsePaginated()
    {
        $total = $this->q->count();
        $this->qApiOrder();
        $this->qApiLimitOffset();
        $this->collection = $this->q->get();

        return [
            'total' => $total,
            'page' => $this->pageCurrentNumber,
            'models' => $this->collection
        ];
    }

    protected function qApiOrder($backendSortArray = [])
    {
        $sortArray = $backendSortArray ?: ($this->state_APPLY_GET_PARAMS ? $this->calcSortNameSortAscData($this->sortName, $this->sortAsc) : []);
        $sortArray = $sortArray ?: $this->sortDefault;
        $this->qOrderByArray($sortArray);
        return $this->q;
    }

    protected function qOrderByArray($orderArray = [])
    {
        if (empty($orderArray)) return $this->q;
        if (is_string($orderArray)) $orderArray = [[$orderArray, 'ASC']];

        foreach ($orderArray as $orderBy) {
            if (count($orderBy) !== 2) continue;
            [$field, $direction] = $orderBy;
            $this->q->orderBy($field, $direction);
        }

        return $this->q;
    }

    protected function qApiLimitOffset($backendLimit = null, $backendPageCurrentNumber = null, $backendVersa = false): BuilderAlias
    {
        $this->pageSize = $backendLimit ?? $this->pageSize;
        $this->pageCurrentNumber = $backendPageCurrentNumber ?? $this->pageCurrentNumber;

        $PG = Data::paginator($this->state_ROWS_TOTAL, $this->pageCurrentNumber, $this->pageSize, $backendVersa);
        $this->pagesTotal = $PG->pages;
        $this->pageCurrentNumber = $PG->page;
        $this->pageSize = $PG->limit;

        $this->q->skip($PG->offset)->take($this->pageSize);

        GlobalRequestStorage::set("{$this->alias}/pageCurrentNumber", $this->pageCurrentNumber);
        GlobalRequestStorage::set("{$this->alias}/pageSize", $this->pageSize);
        GlobalRequestStorage::set("{$this->alias}/rowsTotal", $this->state_ROWS_TOTAL);
        GlobalRequestStorage::set("{$this->alias}/pagesTotal", $this->pagesTotal);

        return $this->q;
    }

    protected function qApiJoinAuditInfo()
    {
        $thisFields = $this->fields();
        $alias = $this->alias;

        if (array_key_exists('created_by', $thisFields)) {
            $this->q->addSelect(['pc.first_name as created_first_name', 'pc.last_name as created_last_name']);
            $this->q->leftJoin('person as pc', 'pc.person_id', '=', "{$alias}.created_by");
        }

        if (array_key_exists('modified_by', $thisFields)) {
            $this->q->addSelect(['pm.first_name as modified_first_name', 'pm.last_name as modified_last_name']);
            $this->q->leftJoin('person as pm', 'pm.person_id', '=', "{$alias}.modified_by");
        }

        return $this->q;
    }

    protected function apiUnpackGetParams()
    {
        $R_GET = Request::obj()->GET;
        $this->o_GET = new stdClass();
        $voc = $this->vocGetSearch();

        foreach ($voc as $short => $full) {
            if (isset($R_GET->{$short})) {
                $this->o_GET->{$full} = $R_GET->{$short};
            }
        }

        if (isset($R_GET->sa)) $this->sortAsc = $R_GET->sa;
        if (isset($R_GET->sn)) $this->sortName = $R_GET->sn;
        if (isset($R_GET->ps)) $this->pageSize = $R_GET->ps;
        if (isset($R_GET->p))  $this->pageCurrentNumber = $R_GET->p;

        return $this->o_GET;
    }
    #endregion

    #region FILTER, VALIDATE
    public function applyFilters(stdClass $data)
    {
        if ($this->state_DATA_FILTERED) return $this;

        $filters = [];
        $fields = $this->fields();

        foreach ($fields as $fieldName => $cfg) {
            if (property_exists($data, $fieldName)) {
                if ($this->mode === self::MODE_INSERT && empty($data->{$fieldName}) && isset($cfg['default'])) {
                    $data->{$fieldName} = $cfg['default'];
                    continue;
                }
                $cfg['filters'][] = [Data::class, 'smartTrim'];
                if (!empty($cfg['filters'])) {
                    $filters[$fieldName] = $cfg['filters'];
                }
            } elseif ($this->mode === self::MODE_INSERT && isset($cfg['default'])) {
                $data->{$fieldName} = $cfg['default'];
            }
        }

        Data::filterObject($data, $filters);
        $this->state_DATA_FILTERED = true;
        return $this;
    }

    public function validate(stdClass $data)
    {
        if ($this->state_DATA_VALIDATED) return $this;

        $validators = [];
        $fields = $this->fields();

        foreach ($fields as $fieldName => $params) {
            if (property_exists($data, $fieldName) && !empty($params['validators'])) {
                $validators[$fieldName] = $params['validators'];
            }
        }

        Data::validateObject($data, $validators);
        $this->validateUniqueKeys($data);
        $this->state_DATA_VALIDATED = true;

        return $this;
    }

    public function validateUniqueKeys($data)
    {
        if ($this->mode === self::MODE_UPDATE && (!property_exists($data, $this->pkName) || empty($data->{$this->pkName}))) {
            return $this;
        }

        if ($this->getModelByUniqueKeys($data)) {
            $fields = strtoupper(implode(', ', $this->matchedUniqueFields));
            $table = strtoupper($this->table);
            $message = ___("{$table} with such {$fields} already exists");
            Message::setDanger($message);
            throw new AppExceptionValidation($message);
        }

        return $this;
    }

    private function restrictIdentityAutoincrementReadOnlyFields($data)
    {
        $dataArray = [];
        $fields = $this->fields();

        foreach ($fields as $name => $params) {
            if (property_exists($data, $name)) {
                if ($this->isFieldIdentity($name)) {
                    $this->dataArrayIdentity[$name] = $data->{$name};
                } else {
                    $dataArray[$name] = $data->{$name};
                }
            }
        }

        return $dataArray;
    }
    #endregion

    #region Helpers
    protected function calcSortNameSortAscData($sortName, $sortAsc)
    {
        if (empty($sortName)) return null;

        $sn = explode(',', $sortName);
        $sa = explode(',', $sortAsc);
        $sortArray = [];

        foreach ($sn as $i => $n) {
            $asc = isset($sa[$i]) ? Data::getSqlDirection($sa[$i]) : 'ASC';
            $sortArray[] = [$n, $asc];
        }

        return $sortArray;
    }

    protected function resetFlags()
    {
        $this->mode = self::MODE_SELECT;
        $this->state_DATA_FILTERED = false;
        $this->state_DATA_VALIDATED = false;
        $this->matchedUniqueFields = [];
        $this->matchedConditions = [];
    }

    public function buildDefaultData()
    {
        $fields = $this->fields();
        $defaultRawObj = new stdClass();

        foreach ($fields as $f => $props) {
            $defaultRawObj->{$f} = $props['default'] ?? null;
        }

        $this->attributes = $defaultRawObj;
        return $this->attributes;
    }

    protected function prepareDbData($data)
    {
        $data = Data::toObject($data);
        $data = Data::mergeObjects($this->attributes, $data);
        unset($data->created_by, $data->modified_by, $data->created_at, $data->modified_at);

        $this->applyFilters($data);
        $this->validate($data);

        if ($this->addAuditInfo) {
            $this->addAuditInfo($data);
        }

        return $this->restrictIdentityAutoincrementReadOnlyFields($data);
    }

    public function tableHasField($fieldName)
    {
        return array_key_exists($fieldName, $this->fields());
    }

    protected function addAuditInfo(stdClass $data, string $saveMode = null)
    {
        $saveMode = $saveMode ?? $this->mode;
        $userId = CurrentUser::id();
        $now = ALINA_TIME;

        if ($this->tableHasField('modified_at')) {
            $data->modified_at = $now;
        }
        if ($this->tableHasField('modified_by')) {
            $data->modified_by = $userId;
        }
        if ($saveMode === self::MODE_INSERT) {
            if ($this->tableHasField('created_at')) {
                $data->created_at = $now;
            }
            if ($this->tableHasField('created_by')) {
                $data->created_by = $userId;
            }
        }
    }

    public function addAuditInfoEventLog($eventData = null, string $eventName = null, string $tableName = null, int $tableId = null)
    {
        $eventName = $eventName ?? $this->mode;
        $tableName = $tableName ?? $this->table;
        $tableId = $tableId ?? $this->id;

        $mAudit = new audit();
        $mAudit->insert([
            'event_name' => $eventName,
            'table_name' => $tableName,
            'table_id' => $tableId,
            'event_data' => json_encode($eventData),
        ]);

        return null;
    }

    public function isFieldIdentity($fieldName)
    {
        return in_array($fieldName, $this->fieldsIdentity());
    }

    protected function uniqueKeys()
    {
        return [];
    }

    protected function fieldsIdentity()
    {
        return [$this->pkName];
    }

    public function q($alias = null)
    {
        if (isset($this->q)) $this->q = null;

        $this->alias = $alias ?? $this->alias;

        $this->q = ($this->mode === self::MODE_INSERT || $this->mode === self::MODE_DELETE || $alias === -1)
            ? Dal::table($this->table)
            : Dal::table("{$this->table} AS {$this->alias}");

        GlobalRequestStorage::setPlus1('BaseModelQueries');
        return $this->q;
    }

    public function x($sql)
    {
        return Dal::connection()->getPdo()->query($sql);
    }

    public function fields()
    {
        $items = Dal::table('information_schema.columns')
            ->select('COLUMN_NAME')
            ->where('table_name', $this->table)
            ->where('table_schema', AlinaCfg('db/database'))
            ->orderBy('ORDINAL_POSITION')
            ->pluck('COLUMN_NAME');

        return array_fill_keys($items, []);
    }

    #region Utility Methods (assumed)
    protected function callHook($method, ...$args)
    {
        if (method_exists($this, $method)) {
            $this->$method(...$args);
        }
    }

    protected function logAudit($data)
    {
        if ($this->flagAuditInfoLog) {
            $this->addAuditInfoEventLog($data, $this->mode, $this->table, $this->id);
        }
    }

    protected function setPkValue($value, $data = null)
    {
        $this->id = $value;
        if ($data && property_exists($data, $this->pkName)) {
            $data->{$this->pkName} = $value;
        }
    }

    protected function qApplyGetSearchParams() { /* assumed empty */ }
    protected function qJoinHasOne() { /* assumed empty */ }
    protected function joinHasMany() { /* assumed empty */ }
    protected function vocGetSearch() { return []; }
    #endregion
}
