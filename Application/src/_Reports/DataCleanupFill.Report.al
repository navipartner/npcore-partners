report 6060100 "NPR Data Cleanup Fill"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Data Cleanup Fill.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Data Cleanup Customer';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = CONST(1));
            column(CleanupAction; CleanupAction)
            {
            }
            column(TableOption; TableOption)
            {
            }
            column(CustFilter; CustFilter)
            {
            }
            column(VendorFilter; VendorFilter)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(GLFilter; GLFilter)
            {
            }
        }
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending);
            RequestFilterFields = "No.";
            column(Cust_No; Customer."No.")
            {
            }
            column(Cust_Name; Customer.Name)
            {
            }
            column(Cust_Deleteable; Deleteable)
            {
            }
            column(Cust_LedgerCnt; LedgerCnt)
            {
            }
            dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No." = FIELD("No.");
                DataItemTableView = SORTING("Customer No.", "Posting Date", "Currency Code") ORDER(Descending);
                RequestFilterFields = "Posting Date";

                trigger OnAfterGetRecord()
                begin
                    Func_LedgerOnAfterGetRec();
                    CurrReport.Break();

                end;

                trigger OnPreDataItem()
                begin
                    Func_LedgerOnPreDataItem();

                end;
            }

            trigger OnAfterGetRecord()
            begin
                if TableOption <> TableOption::Customer then
                    CurrReport.Skip();

                Func_OnAfterGetRec();
            end;
        }
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending);
            RequestFilterFields = "No.";
            column(Vend_No; Vendor."No.")
            {
            }
            column(Vend_Name; Vendor.Name)
            {
            }
            column(Vend_Deleteable; Deleteable)
            {
            }
            column(Vend_LedgerCnt; LedgerCnt)
            {
            }
            dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
            {
                DataItemLink = "Vendor No." = FIELD("No.");
                DataItemTableView = SORTING("Vendor No.", "Posting Date", "Currency Code") ORDER(Descending);
                RequestFilterFields = "Posting Date";

                trigger OnAfterGetRecord()
                begin
                    Func_LedgerOnAfterGetRec();

                    CurrReport.Break();

                end;

                trigger OnPreDataItem()
                begin
                    Func_LedgerOnPreDataItem();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if TableOption <> TableOption::Vendor then
                    CurrReport.Skip();

                Func_OnAfterGetRec();
            end;
        }
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending);
            RequestFilterFields = "No.";
            column(Item_No; Item."No.")
            {
            }
            column(Item_Description; Item.Description)
            {
            }
            column(Item_Deleteable; Deleteable)
            {
            }
            column(Item_LedgerCnt; LedgerCnt)
            {
            }
            dataitem("Item Ledger Entry"; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", "Posting Date") ORDER(Descending);
                RequestFilterFields = "Posting Date";

                trigger OnAfterGetRecord()
                begin
                    Func_LedgerOnAfterGetRec();
                    CurrReport.Break();

                end;

                trigger OnPreDataItem()
                begin
                    Func_LedgerOnPreDataItem();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if TableOption <> TableOption::Item then
                    CurrReport.Skip();

                Func_OnAfterGetRec();
            end;
        }
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending);
            RequestFilterFields = "No.";
            column(GLAcc_No; "G/L Account"."No.")
            {
            }
            column(GLAcc_Name; "G/L Account".Name)
            {
            }
            column(GLAcc_Deleteable; Deleteable)
            {
            }
            column(GLAcc_LedgerCnt; LedgerCnt)
            {
            }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "G/L Account No." = FIELD("No.");
                DataItemTableView = SORTING("G/L Account No.", "Posting Date") ORDER(Ascending);
                RequestFilterFields = "Posting Date";

                trigger OnAfterGetRecord()
                begin
                    Func_LedgerOnAfterGetRec();
                    CurrReport.Break();

                end;

                trigger OnPreDataItem()
                begin
                    Func_LedgerOnPreDataItem();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if TableOption <> TableOption::GLAccount then
                    CurrReport.Skip();

                Func_OnAfterGetRec();
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Fill Table"; FillTable)
                {

                    Caption = 'Insert Data In Table';
                    ToolTip = 'Specifies the value of the Insert Data In Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Cleanup Action"; CleanupAction)
                {

                    Caption = 'Cleanup Action';
                    OptionCaption = 'Delete,Rename';
                    ToolTip = 'Specifies the value of the Cleanup Action field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Option"; TableOption)
                {

                    Caption = 'Table Option';
                    CaptionClass = 'Customer,Vendor,Item,GLAccount';
                    ToolTip = 'Specifies the value of the Table Option field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Rename Option"; ItemRenameOption)
                {

                    Caption = 'Rename Option for Item';
                    OptionCaption = ' ,Vendor Item No.,Vendor + Vendor Item No.';
                    ToolTip = 'Specifies the value of the Rename Option for Item field';
                    ApplicationArea = NPRRetail;
                }
            }
        }

    }


    trigger OnPostReport()
    begin
        Message(Format(RecordsIns) + ' ' + RecInsTxt);
    end;

    trigger OnPreReport()
    begin
        CustFilter := Customer.GetFilters;
        VendorFilter := Vendor.GetFilters;
        ItemFilter := Item.GetFilters;
        GLFilter := "G/L Account".GetFilters;
    end;

    var
        DataCleanupCVI: Record "NPR Data Cleanup GCVI";
        DataCleanupCVILine: Codeunit "NPR Data Cleanup GCVI Line";
        Deleteable: Boolean;
        FillTable: Boolean;
        LedgerCnt: Integer;
        RecordsIns: Integer;
        RecInsTxt: Label 'Records have been inserted.';
        ItemRenameOption: Option " ","Vendor Item No.","Vendor + Vendor Item No.";
        TableOption: Option Customer,Vendor,Item,GLAccount;
        CleanupAction: Option Delete,Rename;
        CustFilter: Text;
        GLFilter: Text;
        ItemFilter: Text;
        VendorFilter: Text;

    local procedure Func_OnAfterGetRec()
    begin
        case TableOption of
            TableOption::Customer:
                begin
                    if CleanupAction = CleanupAction::Delete then begin
                        Deleteable := DataCleanupCVILine.MoveCustEntriesTest(Customer);
                    end;
                    if CleanupAction = CleanupAction::Rename then begin
                        if FillTable then
                            if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Rename, DataCleanupCVI.Type::Customer, Customer."No.") then
                                InsertCVIRec(DataCleanupCVI."Cleanup Action"::Rename, DataCleanupCVI.Type::Customer, Customer."No.", 0D, '');
                    end;
                end;
            TableOption::Vendor:
                begin
                    if CleanupAction = CleanupAction::Delete then begin
                        Deleteable := DataCleanupCVILine.MoveVendorEntriesTest(Vendor);
                    end;
                    if CleanupAction = CleanupAction::Rename then begin
                        if FillTable then
                            if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Rename, DataCleanupCVI.Type::Vendor, Vendor."No.") then
                                InsertCVIRec(DataCleanupCVI."Cleanup Action"::Rename, DataCleanupCVI.Type::Vendor, Vendor."No.", 0D, '');

                    end;
                end;
            TableOption::Item:
                begin
                    if CleanupAction = CleanupAction::Delete then
                        Deleteable := DataCleanupCVILine.MoveItemEntriesTest(Item);
                    if CleanupAction = CleanupAction::Rename then begin
                        if FillTable then
                            if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Rename, DataCleanupCVI.Type::Item, Item."No.") then begin
                                if ItemRenameOption = ItemRenameOption::"Vendor Item No." then
# pragma warning disable AA0139
                                    InsertCVIRec(DataCleanupCVI."Cleanup Action"::Rename, DataCleanupCVI.Type::Item, Item."No.", 0D, Item."Vendor Item No.");
# pragma warning restore
                                if ItemRenameOption = ItemRenameOption::"Vendor + Vendor Item No." then
# pragma warning disable AA0139
                                    InsertCVIRec(DataCleanupCVI."Cleanup Action"::Rename, DataCleanupCVI.Type::Item, Item."No.", 0D, Item."Vendor No." + '-' + Item."Vendor Item No.");
# pragma warning restore
                            end;
                    end;
                end;
            TableOption::GLAccount:
                begin
                    if CleanupAction = CleanupAction::Delete then
                        Deleteable := DataCleanupCVILine.MoveGLEntriesTest("G/L Account");
                    if CleanupAction = CleanupAction::Rename then begin
                        if FillTable then
                            if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Rename, DataCleanupCVI.Type::"G/L Account", "G/L Account"."No.") then
                                InsertCVIRec(DataCleanupCVI."Cleanup Action"::Rename, DataCleanupCVI.Type::"G/L Account", "G/L Account"."No.", 0D, '');

                    end;
                end;
        end;
    end;

    local procedure Func_LedgerOnPreDataItem()
    begin
        if CleanupAction = CleanupAction::Delete then begin
            case TableOption of
                TableOption::Customer:
                    begin
                        LedgerCnt := "Cust. Ledger Entry".Count();
                        if FillTable and Deleteable then begin
                            if LedgerCnt = 0 then
                                if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Customer, Customer."No.") then
                                    InsertCVIRec(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Customer, Customer."No.", "Cust. Ledger Entry"."Posting Date", '');
                        end;
                    end;
                TableOption::Vendor:
                    begin
                        LedgerCnt := "Vendor Ledger Entry".Count();
                        if FillTable and Deleteable then begin
                            if LedgerCnt = 0 then
                                if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Vendor, Vendor."No.") then
                                    InsertCVIRec(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Vendor, Vendor."No.", "Vendor Ledger Entry"."Posting Date", '');
                        end;
                    end;
                TableOption::Item:
                    begin
                        LedgerCnt := "Item Ledger Entry".Count();
                        if FillTable and Deleteable then begin
                            if LedgerCnt = 0 then
                                if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Item, Item."No.") then
                                    InsertCVIRec(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Item, Item."No.", "Item Ledger Entry"."Posting Date", '');
                        end;
                    end;
                TableOption::GLAccount:
                    begin
                        LedgerCnt := "G/L Entry".Count();
                        if FillTable and Deleteable then begin
                            if LedgerCnt = 0 then
                                if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::"G/L Account", "G/L Account"."No.") then
                                    InsertCVIRec(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::"G/L Account", "G/L Account"."No.", "G/L Entry"."Posting Date", '');
                        end;
                    end;
            end;
        end;
    end;

    local procedure Func_LedgerOnAfterGetRec()
    begin
        if CleanupAction = CleanupAction::Delete then begin
            case TableOption of
                TableOption::Customer:
                    begin
                        if FillTable and Deleteable then begin
                            if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Customer, Customer."No.") then
                                InsertCVIRec(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Customer, Customer."No.", "Cust. Ledger Entry"."Posting Date", '');
                        end;
                    end;
                TableOption::Vendor:
                    begin
                        if FillTable and Deleteable then begin
                            if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Vendor, Vendor."No.") then
                                InsertCVIRec(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Vendor, Vendor."No.", "Vendor Ledger Entry"."Posting Date", '');
                        end;
                    end;
                TableOption::Item:
                    begin
                        if FillTable and Deleteable then begin
                            if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Item, Item."No.") then
                                InsertCVIRec(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::Item, Item."No.", "Item Ledger Entry"."Posting Date", '');
                        end;
                    end;
                TableOption::GLAccount:
                    begin
                        if FillTable and Deleteable then begin
                            if not DataCleanupCVI.Get(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::"G/L Account", "G/L Account"."No.") then
                                InsertCVIRec(DataCleanupCVI."Cleanup Action"::Delete, DataCleanupCVI.Type::"G/L Account", "G/L Account"."No.", "G/L Entry"."Posting Date", '');
                        end;
                    end;
            end;
        end;
    end;

    local procedure InsertCVIRec(CleanupAction: Option " ","None",Delete,Rename; Type: Option Customer,Vendor,Item,GLAccount; No: Code[20]; LastEntryDate: Date; NewNo: Code[20])
    var
        InsertedLbl: Label 'INSERTED';
    begin
        DataCleanupCVI."Cleanup Action" := CleanupAction;
        DataCleanupCVI.Type := Type;
        DataCleanupCVI."No." := No;
        DataCleanupCVI.Status := InsertedLbl;
        DataCleanupCVI."Last Entry Date" := LastEntryDate;
        if DataCleanupCVI."Cleanup Action" = DataCleanupCVI."Cleanup Action"::Rename then begin
            DataCleanupCVI."NewNo." := NewNo;
            DataCleanupCVI."xNo." := No;
        end;
        DataCleanupCVI.Insert(true);

        RecordsIns := RecordsIns + 1;
    end;
}

