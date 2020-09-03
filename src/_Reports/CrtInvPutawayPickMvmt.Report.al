report 6151599 "NPR Crt Inv Put-away/Pick/Mvmt"
{
    // NPR5.55/ALST/20200716 CASE 404660 new object created for the task queue

    Caption = 'Create Invt. Put-away/Pick/Movement';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Warehouse Request"; "Warehouse Request")
        {
            DataItemTableView = SORTING("Source Document", "Source No.");
            RequestFilterFields = "Source Document", "Source No.";

            trigger OnAfterGetRecord()
            var
                ATOMvmntCreated: Integer;
                TotalATOMvmtToBeCreated: Integer;
            begin
                Window.Update(1, "Source Document");
                Window.Update(2, "Source No.");

                case Type of
                    Type::Inbound:
                        TotalPutAwayCounter += 1;
                    Type::Outbound:
                        if CreatePick then
                            TotalPickCounter += 1
                        else
                            TotalMovementCounter += 1;
                end;

                if CheckWhseRequest("Warehouse Request") then
                    CurrReport.Skip;

                if ((Type = Type::Inbound) and (WhseActivHeader.Type <> WhseActivHeader.Type::"Invt. Put-away")) or
                   ((Type = Type::Outbound) and ((WhseActivHeader.Type <> WhseActivHeader.Type::"Invt. Pick") and
                                                 (WhseActivHeader.Type <> WhseActivHeader.Type::"Invt. Movement"))) or
                   ("Source Type" <> WhseActivHeader."Source Type") or
                   ("Source Subtype" <> WhseActivHeader."Source Subtype") or
                   ("Source No." <> WhseActivHeader."Source No.") or
                   ("Location Code" <> WhseActivHeader."Location Code")
                then begin
                    case Type of
                        Type::Inbound:
                            if not CreateInvtPutAway.CheckSourceDoc("Warehouse Request") then
                                CurrReport.Skip;
                        Type::Outbound:
                            if not CreateInvtPickMovement.CheckSourceDoc("Warehouse Request") then
                                CurrReport.Skip;
                    end;
                    InitWhseActivHeader;
                end;

                case Type of
                    Type::Inbound:
                        begin
                            CreateInvtPutAway.SetWhseRequest("Warehouse Request", true);
                            CreateInvtPutAway.AutoCreatePutAway(WhseActivHeader);
                        end;
                    Type::Outbound:
                        begin
                            CreateInvtPickMovement.SetWhseRequest("Warehouse Request", true);
                            CreateInvtPickMovement.AutoCreatePickOrMove(WhseActivHeader);
                        end;
                end;

                if WhseActivHeader."No." <> '' then begin
                    DocumentCreated := true;
                    case Type of
                        Type::Inbound:
                            PutAwayCounter := PutAwayCounter + 1;
                        Type::Outbound:
                            if CreatePick then begin
                                PickCounter := PickCounter + 1;

                                CreateInvtPickMovement.GetATOMovementsCounters(ATOMvmntCreated, TotalATOMvmtToBeCreated);
                                MovementCounter += ATOMvmntCreated;
                                TotalMovementCounter += TotalATOMvmtToBeCreated;
                            end else
                                MovementCounter += 1;
                    end;
                    if PrintDocument then
                        InsertTempWhseActivHdr;
                    Commit;
                end;
            end;

            trigger OnPostDataItem()
            var
                ExpiredItemMessageText: Text[100];
                Msg: Text;
            begin
                ExpiredItemMessageText := CreateInvtPickMovement.GetExpiredItemMessage;
                if TempWhseActivHdr.Find('-') then
                    PrintNewDocuments;

                Window.Close;
                if not SuppressMessagesState then
                    if DocumentCreated then begin
                        if PutAwayCounter > 0 then
                            AddToText(Msg, StrSubstNo(Text005, WhseActivHeader.Type::"Invt. Put-away", PutAwayCounter, TotalPutAwayCounter));
                        if PickCounter > 0 then
                            AddToText(Msg, StrSubstNo(Text005, WhseActivHeader.Type::"Invt. Pick", PickCounter, TotalPickCounter));
                        if MovementCounter > 0 then
                            AddToText(Msg, StrSubstNo(Text005, WhseActivHeader.Type::"Invt. Movement", MovementCounter, TotalMovementCounter));

                        if CreatePutAway or CreatePick then
                            Msg += ExpiredItemMessageText;

                        Message(Msg);
                    end else begin
                        Msg := Text004 + ' ' + ExpiredItemMessageText;
                        Message(Msg);
                    end;
            end;

            trigger OnPreDataItem()
            begin
                if CreatePutAway and not (CreatePick or CreateMovement) then
                    SetRange(Type, Type::Inbound);
                if not CreatePutAway and (CreatePick or CreateMovement) then
                    SetRange(Type, Type::Outbound);

                Window.Open(
                  Text001 +
                  Text002 +
                  Text003);

                DocumentCreated := false;

                if CreatePick or CreateMovement then
                    CreateInvtPickMovement.SetReportGlobals(PrintDocument, ShowError);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(CreateInventorytPutAway; CreatePutAway)
                    {
                        Caption = 'Create Invt. Put-Away';
                    }
                    field(CInvtPick; CreatePick)
                    {
                        Caption = 'Create Invt. Pick';
                        Editable = CreatePickEditable;
                        Enabled = CreatePickEditable;

                        trigger OnValidate()
                        begin
                            if CreatePick and CreateMovement then
                                Error(Text009);
                            EnableFieldsInPage;
                        end;
                    }
                    field(CInvtMvmt; CreateMovement)
                    {
                        Caption = 'Create Invt. Movement';
                        Editable = CreateMovementEditable;
                        Enabled = CreateMovementEditable;

                        trigger OnValidate()
                        begin
                            if CreatePick and CreateMovement then
                                Error(Text009);
                            EnableFieldsInPage;
                        end;
                    }
                    field(PrintDocument; PrintDocument)
                    {
                        Caption = 'Print Document';
                    }
                    field(ShowError; ShowError)
                    {
                        Caption = 'Show Error';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            CreatePickEditable := true;
            CreateMovementEditable := true;
        end;

        trigger OnOpenPage()
        begin
            EnableFieldsInPage;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        SuppressMessages(not GuiAllowed);
    end;

    trigger OnPostReport()
    begin
        TempWhseActivHdr.DeleteAll;
    end;

    trigger OnPreReport()
    begin
        if not CreatePutAway and not (CreatePick or CreateMovement) then
            Error(Text008);

        CreateInvtPickMovement.SetInvtMovement(CreateMovement);
    end;

    var
        WhseActivHeader: Record "Warehouse Activity Header";
        TempWhseActivHdr: Record "Warehouse Activity Header" temporary;
        CreateInvtPutAway: Codeunit "Create Inventory Put-away";
        CreateInvtPickMovement: Codeunit "Create Inventory Pick/Movement";
        WhseDocPrint: Codeunit "Warehouse Document-Print";
        Window: Dialog;
        CreatePutAway: Boolean;
        CreatePick: Boolean;
        Text001: Label 'Creating Inventory Activities...\\';
        Text002: Label 'Source Type     #1##########\';
        Text003: Label 'Source No.      #2##########';
        CreateMovement: Boolean;
        DocumentCreated: Boolean;
        PrintDocument: Boolean;
        PutAwayCounter: Integer;
        PickCounter: Integer;
        MovementCounter: Integer;
        Text004: Label 'There is nothing to create.';
        Text005: Label 'Number of %1 activities created: %2 out of a total of %3.';
        Text006: Label '%1\\%2', Comment = 'No translation needed. Only a new line separator.';
        Text008: Label 'You must select Create Invt. Put-away, Create Invt. Pick, or Create Invt. Movement.';
        TotalPutAwayCounter: Integer;
        TotalPickCounter: Integer;
        TotalMovementCounter: Integer;
        ShowError: Boolean;
        Text009: Label 'You can select either Create Invt. Pick or Create Invt. Movement.';
        [InDataSet]
        CreatePickEditable: Boolean;
        [InDataSet]
        CreateMovementEditable: Boolean;
        SuppressMessagesState: Boolean;

    local procedure InitWhseActivHeader()
    begin
        with WhseActivHeader do begin
            Init;
            case "Warehouse Request".Type of
                "Warehouse Request".Type::Inbound:
                    Type := Type::"Invt. Put-away";
                "Warehouse Request".Type::Outbound:
                    if CreatePick then
                        Type := Type::"Invt. Pick"
                    else
                        Type := Type::"Invt. Movement";
            end;
            "No." := '';
            "Location Code" := "Warehouse Request"."Location Code";
        end;
    end;

    local procedure InsertTempWhseActivHdr()
    begin
        TempWhseActivHdr.Init;
        TempWhseActivHdr := WhseActivHeader;
        TempWhseActivHdr.Insert;
    end;

    local procedure PrintNewDocuments()
    begin
        with TempWhseActivHdr do begin
            repeat
                case Type of
                    Type::"Invt. Put-away":
                        WhseDocPrint.PrintInvtPutAwayHeader(TempWhseActivHdr, true);
                    Type::"Invt. Pick":
                        if CreatePick then
                            WhseDocPrint.PrintInvtPickHeader(TempWhseActivHdr, true)
                        else
                            WhseDocPrint.PrintInvtMovementHeader(TempWhseActivHdr, true);
                end;
            until Next = 0;
        end;
    end;

    local procedure CheckWhseRequest(WhseRequest: Record "Warehouse Request"): Boolean
    var
        SalesHeader: Record "Sales Header";
        TransferHeader: Record "Transfer Header";
        GetSrcDocOutbound: Codeunit "Get Source Doc. Outbound";
    begin
        if WhseRequest."Document Status" <> WhseRequest."Document Status"::Released then
            exit(true);
        if (WhseRequest.Type = WhseRequest.Type::Outbound) and
           (WhseRequest."Shipping Advice" = WhseRequest."Shipping Advice"::Complete)
        then
            case WhseRequest."Source Type" of
                DATABASE::"Sales Line":
                    if WhseRequest."Source Subtype" = WhseRequest."Source Subtype"::"1" then begin
                        SalesHeader.Get(SalesHeader."Document Type"::Order, WhseRequest."Source No.");
                        exit(GetSrcDocOutbound.CheckSalesHeader(SalesHeader, ShowError));
                    end;
                DATABASE::"Transfer Line":
                    begin
                        TransferHeader.Get(WhseRequest."Source No.");
                        exit(GetSrcDocOutbound.CheckTransferHeader(TransferHeader, ShowError));
                    end;
            end;
    end;

    procedure InitializeRequest(NewCreateInvtPutAway: Boolean; NewCreateInvtPick: Boolean; NewCreateInvtMovement: Boolean; NewPrintDocument: Boolean; NewShowError: Boolean)
    begin
        CreatePutAway := NewCreateInvtPutAway;
        CreatePick := NewCreateInvtPick;
        CreateMovement := NewCreateInvtMovement;
        PrintDocument := NewPrintDocument;
        ShowError := NewShowError;
    end;

    local procedure EnableFieldsInPage()
    begin
        CreatePickEditable := not CreateMovement;
        CreateMovementEditable := not CreatePick;
    end;

    procedure SuppressMessages(NewState: Boolean)
    begin
        SuppressMessagesState := NewState;
    end;

    local procedure AddToText(var OrigText: Text; Addendum: Text)
    begin
        if OrigText = '' then
            OrigText := Addendum
        else
            OrigText := StrSubstNo(Text006, OrigText, Addendum);
    end;

    procedure GetMovementCounters(var MovementsCreated: Integer; var TotalMovementsToBeCreated: Integer)
    begin
        MovementsCreated := MovementCounter;
        TotalMovementsToBeCreated := TotalMovementCounter;
    end;
}

