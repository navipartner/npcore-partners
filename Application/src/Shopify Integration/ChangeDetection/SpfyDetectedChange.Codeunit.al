codeunit 6151184 "NPR Spfy Detected Change"
{
    Access = Internal;

    var
        _IntegrationArea: Enum "NPR Spfy Integration Area";
        _ChangeType: Enum "NPR Spfy Change Type";
        _TableNo: Integer;
        _RecordId: RecordId;
        _SystemId: Guid;
        _StoreCode: Code[20];
        _ShopifyIdType: Enum "NPR Spfy ID Type";
        _ShopifyId: Text[30];
        _ItemNo: Code[20];
        _VariantCode: Code[10];
        _CustomerNo: Code[20];
        _DeletionLogEntryNo: BigInteger;
        _CreatedNcTaskEntryNo: BigInteger;
        _CreatedTaskQueue: Enum "NPR Spfy Task Dest Queue";

    procedure Init(IntegrationAreaParam: Enum "NPR Spfy Integration Area"; ChangeTypeParam: Enum "NPR Spfy Change Type"; TableNoParam: Integer; RecordIdParam: RecordId; SystemIdParam: Guid)
    begin
        Clear(_StoreCode);
        Clear(_ShopifyId);
        Clear(_ItemNo);
        Clear(_VariantCode);
        Clear(_CustomerNo);
        Clear(_DeletionLogEntryNo);
        Clear(_CreatedNcTaskEntryNo);
        Clear(_CreatedTaskQueue);
        _IntegrationArea := IntegrationAreaParam;
        _ChangeType := ChangeTypeParam;
        _TableNo := TableNoParam;
        _RecordId := RecordIdParam;
        _SystemId := SystemIdParam;
    end;

    procedure IntegrationArea(): Enum "NPR Spfy Integration Area"
    begin
        exit(_IntegrationArea);
    end;

    procedure SetTombstone(StoreCodeParam: Code[20]; ShopifyIdTypeParam: Enum "NPR Spfy ID Type"; ShopifyIdParam: Text[30])
    begin
        _StoreCode := StoreCodeParam;
        _ShopifyIdType := ShopifyIdTypeParam;
        _ShopifyId := ShopifyIdParam;
    end;

    procedure ChangeType(): Enum "NPR Spfy Change Type"
    begin
        exit(_ChangeType);
    end;

    procedure TableNo(): Integer
    begin
        exit(_TableNo);
    end;

    procedure RecordId(): RecordId
    begin
        exit(_RecordId);
    end;

    procedure SystemId(): Guid
    begin
        exit(_SystemId);
    end;

    procedure StoreCode(): Code[20]
    begin
        exit(_StoreCode);
    end;

    procedure ShopifyIdType(): Enum "NPR Spfy ID Type"
    begin
        exit(_ShopifyIdType);
    end;

    procedure ShopifyId(): Text[30]
    begin
        exit(_ShopifyId);
    end;

    procedure SetDeleteRouting(ItemNoParam: Code[20]; VariantCodeParam: Code[10]; CustomerNoParam: Code[20]; DeletionLogEntryNoParam: BigInteger)
    begin
        _ItemNo := ItemNoParam;
        _VariantCode := VariantCodeParam;
        _CustomerNo := CustomerNoParam;
        _DeletionLogEntryNo := DeletionLogEntryNoParam;
    end;

    procedure ItemNo(): Code[20]
    begin
        exit(_ItemNo);
    end;

    procedure VariantCode(): Code[10]
    begin
        exit(_VariantCode);
    end;

    procedure CustomerNo(): Code[20]
    begin
        exit(_CustomerNo);
    end;

    procedure DeletionLogEntryNo(): BigInteger
    begin
        exit(_DeletionLogEntryNo);
    end;

    procedure SetCreatedNcTaskEntryNo(NcTaskEntryNoParam: BigInteger)
    begin
        _CreatedNcTaskEntryNo := NcTaskEntryNoParam;
    end;

    procedure CreatedNcTaskEntryNo(): BigInteger
    begin
        exit(_CreatedNcTaskEntryNo);
    end;

    procedure SetCreatedTaskQueue(TaskQueueParam: Enum "NPR Spfy Task Dest Queue")
    begin
        _CreatedTaskQueue := TaskQueueParam;
    end;

    procedure CreatedTaskQueue(): Enum "NPR Spfy Task Dest Queue"
    begin
        exit(_CreatedTaskQueue);
    end;
}
