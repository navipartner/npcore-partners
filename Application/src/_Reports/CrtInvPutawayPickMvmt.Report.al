report 6151599 "NPR Crt Inv Put-away/Pick/Mvmt"
{
    Caption = 'Create Invt. Put-away/Pick/Movement';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
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
                    CurrReport.Skip();

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
                                CurrReport.Skip();
                        Type::Outbound:
                            if not CreateInvtPickMovement.CheckSourceDoc("Warehouse Request") then
                                CurrReport.Skip();
                    end;
                    InitWhseActivHeader();
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
                        InsertTempWhseActivHdr();
                    Commit();
                end;
            end;

            trigger OnPostDataItem()
            var
                Msg: Text;
                ExpiredItemMessageText: Text[100];
            begin
                ExpiredItemMessageText := CreateInvtPickMovement.GetExpiredItemMessage();
                if TempWhseActivHdr.Find('-') then
                    PrintNewDocuments();

                Window.Close();
                if not SuppressMessagesState then
                    if DocumentCreated then begin
                        if PutAwayCounter > 0 then
                            AddToText(Msg, StrSubstNo(CreatedActivitiesLbl, WhseActivHeader.Type::"Invt. Put-away", PutAwayCounter, TotalPutAwayCounter));
                        if PickCounter > 0 then
                            AddToText(Msg, StrSubstNo(CreatedActivitiesLbl, WhseActivHeader.Type::"Invt. Pick", PickCounter, TotalPickCounter));
                        if MovementCounter > 0 then
                            AddToText(Msg, StrSubstNo(CreatedActivitiesLbl, WhseActivHeader.Type::"Invt. Movement", MovementCounter, TotalMovementCounter));

                        if CreatePutAway or CreatePick then
                            Msg += ExpiredItemMessageText;

                        Message(Msg);
                    end else begin
                        Msg := NothingCreatedLbl + ' ' + ExpiredItemMessageText;
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
                  CreatingActivitiesLbl +
                  SourceTypeLbl +
                  SourceNoLbl);

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
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Create Invt. Put-Away field';
                    }
                    field(CInvtPick; CreatePick)
                    {
                        Caption = 'Create Invt. Pick';
                        Editable = CreatePickEditable;
                        Enabled = CreatePickEditable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Create Invt. Pick field';

                        trigger OnValidate()
                        begin
                            if CreatePick and CreateMovement then
                                Error(SelectionErr);
                            EnableFieldsInPage();
                        end;
                    }
                    field(CInvtMvmt; CreateMovement)
                    {
                        Caption = 'Create Invt. Movement';
                        Editable = CreateMovementEditable;
                        Enabled = CreateMovementEditable;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Create Invt. Movement field';

                        trigger OnValidate()
                        begin
                            if CreatePick and CreateMovement then
                                Error(SelectionErr);
                            EnableFieldsInPage();
                        end;
                    }
                    field("Print Document"; PrintDocument)
                    {
                        Caption = 'Print Document';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print Document field';
                    }
                    field("Show Error"; ShowError)
                    {
                        Caption = 'Show Error';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Error field';
                    }
                }
            }
        }

        trigger OnInit()
        begin
            CreatePickEditable := true;
            CreateMovementEditable := true;
        end;

        trigger OnOpenPage()
        begin
            EnableFieldsInPage();
        end;
    }


    trigger OnInitReport()
    begin
        SuppressMessages(not GuiAllowed);
    end;

    trigger OnPostReport()
    begin
        TempWhseActivHdr.DeleteAll();
    end;

    trigger OnPreReport()
    begin
        if not CreatePutAway and not (CreatePick or CreateMovement) then
            Error(SelectErr);

        CreateInvtPickMovement.SetInvtMovement(CreateMovement);
    end;

    var
        TempWhseActivHdr: Record "Warehouse Activity Header" temporary;
        WhseActivHeader: Record "Warehouse Activity Header";
        CreateInvtPickMovement: Codeunit "Create Inventory Pick/Movement";
        CreateInvtPutAway: Codeunit "Create Inventory Put-away";
        WhseDocPrint: Codeunit "Warehouse Document-Print";
        CreateMovement: Boolean;
        [InDataSet]
        CreateMovementEditable: Boolean;
        CreatePick: Boolean;
        [InDataSet]
        CreatePickEditable: Boolean;
        CreatePutAway: Boolean;
        DocumentCreated: Boolean;
        PrintDocument: Boolean;
        ShowError: Boolean;
        SuppressMessagesState: Boolean;
        Window: Dialog;
        MovementCounter: Integer;
        PickCounter: Integer;
        PutAwayCounter: Integer;
        TotalMovementCounter: Integer;
        TotalPickCounter: Integer;
        TotalPutAwayCounter: Integer;
        TextLbl: Label '%1\\%2', Comment = 'No translation needed. Only a new line separator.';
        CreatingActivitiesLbl: Label 'Creating Inventory Activities...\\';
        CreatedActivitiesLbl: Label 'Number of %1 activities created: %2 out of a total of %3.', Comment = '%1 = Type of Activities, %2 = Created Activities, %3 = Total Activities';
        SourceNoLbl: Label 'Source No.      #2##########';
        SourceTypeLbl: Label 'Source Type     #1##########\';
        NothingCreatedLbl: Label 'There is nothing to create.';
        SelectionErr: Label 'You can select either Create Invt. Pick or Create Invt. Movement.';
        SelectErr: Label 'You must select Create Invt. Put-away, Create Invt. Pick, or Create Invt. Movement.';

    local procedure InitWhseActivHeader()
    begin
        WhseActivHeader.Init();
        case "Warehouse Request".Type of
            "Warehouse Request".Type::Inbound:
                WhseActivHeader.Type := WhseActivHeader.Type::"Invt. Put-away";
            "Warehouse Request".Type::Outbound:
                if CreatePick then
                    WhseActivHeader.Type := WhseActivHeader.Type::"Invt. Pick"
                else
                    WhseActivHeader.Type := WhseActivHeader.Type::"Invt. Movement";
        end;
        WhseActivHeader."No." := '';
        WhseActivHeader."Location Code" := "Warehouse Request"."Location Code";
    end;

    local procedure InsertTempWhseActivHdr()
    begin
        TempWhseActivHdr.Init();
        TempWhseActivHdr := WhseActivHeader;
        TempWhseActivHdr.Insert();
    end;

    local procedure PrintNewDocuments()
    begin
        repeat
            case TempWhseActivHdr.Type of
                TempWhseActivHdr.Type::"Invt. Put-away":
                    WhseDocPrint.PrintInvtPutAwayHeader(TempWhseActivHdr, true);
                TempWhseActivHdr.Type::"Invt. Pick":
                    if CreatePick then
                        WhseDocPrint.PrintInvtPickHeader(TempWhseActivHdr, true)
                    else
                        WhseDocPrint.PrintInvtMovementHeader(TempWhseActivHdr, true);
            end;
        until TempWhseActivHdr.Next() = 0;
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
            OrigText := StrSubstNo(TextLbl, OrigText, Addendum);
    end;

    procedure GetMovementCounters(var MovementsCreated: Integer; var TotalMovementsToBeCreated: Integer)
    begin
        MovementsCreated := MovementCounter;
        TotalMovementsToBeCreated := TotalMovementCounter;
    end;
}

