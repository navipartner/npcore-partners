codeunit 85083 "NPR Library Click & Collect"
{
    Access = Internal;

    procedure CheckCollectWS()
    var
        WebServiceManagement: Codeunit "Web Service Management";
        WebService: Record "Web Service Aggregate";
    begin
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, CollectWsCodeunitId(), 'collect_in_store_service', true);
    end;

    local procedure CollectWsCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Collect WS");
    end;

    procedure CreateLocalCollectStore() NpCsStoreCode: Code[20]
    var
        LibraryUtility: Codeunit "Library - Utility";
        NpCsStore: Record "NPR NpCs Store";
    begin
        NpCsStoreCode := LibraryUtility.CreateCodeRecord(Database::"NPR NpCs Store");
        NpCsStore.SetRange(Code, NpCsStoreCode);
        NpCsStore.SetRange("Company Name", CompanyName());
        if not NpCsStore.FindFirst() then begin
            NpCsStore.Init();
            NpCsStore.Validate(Code, NpCsStoreCode);
            NpCsStore.Validate("Company Name", CompanyName());
            if NpCsStore.Insert() then;
        end;
    end;

    procedure CreateWorkflowRel(NpCsStoreCode: Code[20]; WorkflowCode: Code[20])
    var
        NpCsStoreWorkflowRel: Record "NPR NpCs Store Workflow Rel.";
    begin
        NpCsStoreWorkflowRel.SetRange("Store Code", NpCsStoreCode);
        NpCsStoreWorkflowRel.SetRange("Workflow Code", WorkflowCode);
        if not NpCsStoreWorkflowRel.FindFirst() then begin
            NpCsStoreWorkflowRel.Init();
            NpCsStoreWorkflowRel.Validate("Store Code", NpCsStoreCode);
            NpCsStoreWorkflowRel."Workflow Code" := WorkflowCode;
            NpCsStoreWorkflowRel.Insert();
        end;
    end;

    procedure CreateCollectWF(NpCsWorkflowModule: Record "NPR NpCs Workflow Module"): Code[20]
    var
        LibraryUtility: Codeunit "Library - Utility";
        NpCsWF: Record "NPR NpCs Workflow";
    begin
        NpCsWF.SetRange("Send Order Module", NpCsWorkflowModule.Code);
        if not NpCsWF.FindFirst() then begin
            NpCsWF.Init();
            NpCsWF.Validate(Code, LibraryUtility.GenerateRandomCode20(NpCsWF.FieldNo(Code), Database::"NPR NpCs Workflow"));
            NpCsWF.Validate("Send Order Module", NpCsWorkflowModule.Code);
            NpCsWF.Insert();
        end;
        exit(NpCsWF.Code);
    end;

    procedure CreateSalesOrderWF(var NpCsWorkflowModule: Record "NPR NpCs Workflow Module")
    var
        CreateCollectOrderLbl: Label 'Create Collect Sales Order in Store';
    begin
        if not NpCsWorkflowModule.WritePermission then
            exit;

        if NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Send Order", 'SALES_ORDER') then
            exit;

        NpCsWorkflowModule.Init();
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Send Order";
        NpCsWorkflowModule.Code := 'SALES_ORDER';
        NpCsWorkflowModule.Description := CopyStr(CreateCollectOrderLbl, 1, MaxStrLen(NpCsWorkflowModule.Description));
        NpCsWorkflowModule."Event Codeunit ID" := CODEUNIT::"NPR NpCs Send Order";
        NpCsWorkflowModule.Insert(true);
    end;

    local procedure CreateOrderStatusWF(var NpCsWorkflowModule: Record "NPR NpCs Workflow Module")
    var
        CreateOrderStatusLbl: Label 'Collect in Store Document is first Processed by Store and then Delivered';
    begin
        if not NpCsWorkflowModule.WritePermission then
            exit;

        if NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Order Status", 'ORDER_STATUS') then
            exit;

        NpCsWorkflowModule.Init();
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowModule.Code := 'ORDER_STATUS';
        NpCsWorkflowModule.Description := CopyStr(CreateOrderStatusLbl, 1, MaxStrLen(NpCsWorkflowModule.Description));
        NpCsWorkflowModule."Event Codeunit ID" := CODEUNIT::"NPR NpCs Upd. Order Status";
        NpCsWorkflowModule.Insert(true);
    end;
}