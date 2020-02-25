page 6014456 "Table Export Wizard"
{
    // NPR4.16/JDH /20151016  CASE 225285 Removed references to DBI and Old NAS Module
    // NPR5.20/JDH /20160121  CASE 232476 Removed reference to deferred NAV standard table
    // NPR5.20/OSFI/20160207  CASE 233986 Added check for TableData permission before exporting in InsertTablesWithData()
    // 
    // NPR5.23/THRO/20160425  CASE 234161 Added Save and Load functionality
    //                                    Changed subpage for tablefilters
    //                                    Added tablefilters to the Export function
    //                                    Delete records in fields and table filter when deleting a record
    // NPR5.23/JDH /20160512  CASE 240916 Deleted Varia X and Color size functionality
    // NPR5.25/TS  /20160624  CASE 245266 Added extra Tables
    // NPR5.25/TS  /20160628  CASE 245437 Added Pepper Tables
    // NPR5.25/TS  /20160630  CASE 245905 Added Connection Profiles
    // NPR5.33/JDH /20170621  CASE 280329 Removed "InsertOfflineSetup" function
    // NPR5.38/MHA /20180105  CASE 301053 Removed FileMode::ADOStream
    // NPR5.38/LS  /20171207 CASE 291216  Exclude Exchange tables in Export
    // NPR5.40/LS  /20180426  CASE 306844 Exclude Exchange And MicrosoftGraph tables
    // NPR5.40/LS  /20180327  CASE 309303 Changed Actions "IncludeMasterData", "IncludeAllDataTables", "IncludeWebData"
    //                                    Added Global Var "AllDataCategory", Modified function InsertTablesWithData
    //                                    Added new Action Groups "ExcludingTransactions" and "IncludingTransactions" with new actions
    // NPR5.41/THRO/20180410  CASE 308570 Option to use xml-format for field values
    // NPR5.41/LS  /20180424  CASE 311855 Moved, renamed and re-arranged Actions, changed tables to be excluded + updated function InsertTablesWithData
    //                                    Moved Action "IncludeBaseData" and removed promoted
    // NPR5.44/JDH /20180718 CASE 322867  Added New export function to transfer Demo Company Data
    // NPR5.45/JDH /20180718 CASE 322867  Added New export function to transfer Demo Company Data
    // NPR5.46/NPKNAV/20181008  CASE 322752 Transport NPR5.46 - 8 October 2018
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.48/MMV /20181214 CASE 340086 ISEMPTY instead of COUNT when adding tables.
    //                                   Changed default parameters.
    //                                   Added escape character parameter.
    //                                   Add table fields by default.
    // NPR5.51/ZESO/20190703 CASE 319037 Added Ticketing and Membership tables.
    // NPR5.52/SARA/20190916 CASE 368197 Refcator Table Export wizard for Webclient.
    // NPR5.53/ZESO/20200106 CASE 382903 Exclude fields which have are Obsolete
    // NPR5.53/THRO/20200204 CASE 385785 Skip Obsolete tables

    Caption = 'Table Export Wizard';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Execution,Template,Data,DBI,Setup,Test8';
    SourceTable = AllObj;
    SourceTableTemporary = true;
    SourceTableView = SORTING ("Object Type", "Object ID")
                      ORDER(Ascending)
                      WHERE ("Object Type" = CONST (Table));
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Object ID";"Object ID")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AllObjects: Page "All Objects";
                        AllObj: Record AllObj;
                        ac: Action;
                    begin
                        AllObj.SetRange("Object Type",AllObj."Object Type"::Table);

                        if "Object ID" > 0 then
                          if AllObj.Get(AllObj."Object Type"::Table,"Object ID") then;

                        AllObjects.SetTableView(AllObj);
                        AllObjects.SetRecord(AllObj);
                        AllObjects.LookupMode(true);

                        if AllObjects.RunModal = ACTION::LookupOK then begin
                          AllObjects.GetRecord(AllObj);
                          TransferFields(AllObj);
                          Insert;
                          //-NPR5.48 [340086]
                          AddTableFields("Object ID");
                          //+NPR5.48 [340086]
                        end;
                    end;

                    trigger OnValidate()
                    var
                        AllObj: Record AllObj;
                    begin
                        AllObj.Get(AllObj."Object Type"::Table, "Object ID");
                        "Object Name" := AllObj."Object Name";
                        //-NPR5.48 [340086]
                        AddTableFields("Object ID");
                        //+NPR5.48 [340086]
                    end;
                }
                field("Object Name";"Object Name")
                {
                    Editable = false;
                }
            }
            group(Control6014410)
            {
                ShowCaption = false;
                part("Fields";"Table Export Wizard Fields")
                {
                    Caption = 'Fields';
                    SubPageLink = TableNo=FIELD("Object ID");
                }
                part(TableFilters;"Export Wizard Filters")
                {
                    SubPageLink = "Table Number"=FIELD("Object ID");
                    SubPageView = SORTING("Table Number","Line No.");
                }
            }
            grid(Control6014423)
            {
                ShowCaption = false;
                group(Formatting)
                {
                    Caption = 'Formatting';
                    field(FieldStartDelimeter; FieldStartDelimeter)
                    {
                        Caption = 'Field Start Delimeter';
                    }
                    field(FieldEndDelimeter; FieldEndDelimeter)
                    {
                        Caption = 'Field End Delimeter';
                    }
                    field(FieldSeparator; FieldSeparator)
                    {
                        Caption = 'Field Separator';
                    }
                    field(RecordSeparator; RecordSeparator)
                    {
                        Caption = 'Record Separator';
                    }
                    field(DataItemSeparator; DataItemSeparator)
                    {
                        Caption = 'Data Item Separator';
                    }
                    field(EscapeCharacter; EscapeCharacter)
                    {
                        Caption = 'Escape Character';
                    }
                    field(ExportDataInXmlFormat; ExportDataInXmlFormat)
                    {
                        Caption = 'Use Xml-Format';
                    }
                }
                group("Data Settings")
                {
                    Caption = 'Data Settings';
                    field(UseCompanyName; UseCompanyName)
                    {
                        Caption = 'Company';
                    }
                    field(OutFileEncoding; OutFileEncoding)
                    {
                        Caption = 'File Encoding';
                    }
                    field(FileMode; FileMode)
                    {
                        Caption = 'File Mode';
                    }
                    field(SkipFlowFields; SkipFlowFields)
                    {
                        Caption = 'Skip Flow Fields';
                    }
                }
                group("Export Settings")
                {
                    Caption = 'Export Settings';
                    field(RaiseErrors; RaiseErrors)
                    {
                        Caption = 'Raise Errors';
                    }
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(Run)
            {
                Caption = 'Run';
                Image = Export;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                begin
                    RunExport();
                end;
            }
            action(DeleteAlll)
            {
                Caption = 'Delete All';
                Image = DeleteQtyToHandle;
                Promoted = true;
                PromotedCategory = Category6;

                trigger OnAction()
                begin
                    ClearTableInfo();
                end;
            }
        }
        area(processing)
        {
            group(ActionGroup6150649)
            {
                Caption = 'Setup';
                action(SaveSetup)
                {
                    Caption = 'Save';
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Category7;

                    trigger OnAction()
                    begin
                        //-NPR5.23
                        SaveSetup;
                        //+NPR5.23
                    end;
                }
                action(LoadSetup)
                {
                    Caption = 'Load';
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Category7;

                    trigger OnAction()
                    begin
                        //-NPR5.23
                        LoadSetup;
                        //+NPR5.23
                    end;
                }
            }
            group(ExcludingTransactions)
            {
                Caption = 'Excluding Transactions';
                action(RetailExclTransactions)
                {
                    Caption = 'Add Retail Setup';
                    Image = Default;

                    trigger OnAction()
                    begin
                        //-NPR5.40 [309303]
                        // Retail Master And Setup only excluding Transactions
                        InsertTablesWithData(AllDataCategory::"Retail Master");
                        //+NPR5.40 [309303]
                    end;
                }
                action(StdTablesExclTransactions)
                {
                    Caption = 'Add Std. Nav. Master & Setup';
                    Image = Default;

                    trigger OnAction()
                    begin
                        //-NPR5.40 [309303]
                        // Std Master and Setup Tables only excluding Transactions
                        InsertTablesWithData(AllDataCategory::"Std Master");
                        //+NPR5.40 [309303]
                    end;
                }
                action(StdRetailExclTransactions)
                {
                    Caption = 'Add Std Nav. and Retail Master & Setup';
                    Image = Default;

                    trigger OnAction()
                    begin
                        //-NPR5.40 [309303]
                        // Std and Retail Master and Setup tables Excluding Transactions
                        InsertTablesWithData(AllDataCategory::"StdRetail Master");
                        //+NPR5.40 [309303]
                    end;
                }
                action(ExcludeTransactionTables)
                {
                    Caption = 'Add All Tables Excl. Ticketing/Membership';
                    Image = Default;

                    trigger OnAction()
                    begin
                        //-NPR5.40 [309303]
                        // All Master and Setup Tables
                        InsertTablesWithData(AllDataCategory::"All Master");
                        //+NPR5.40 [309303]
                    end;
                }
                action(TicketingMasterSetupTables)
                {
                    Caption = 'Add Ticketing Master and Setup Tables';
                    Image = Default;

                    trigger OnAction()
                    begin
                        //-NPR5.51 [319037]
                        InsertTablesWithData(AllDataCategory::TicketingSetupMaster);
                        //-NPR5.51 [319037]
                    end;
                }
                action(MembershipMasterSetupTables)
                {
                    Caption = 'Add Membership Master and Setup Tables';
                    Image = Default;

                    trigger OnAction()
                    begin
                        //-NPR5.51 [319037]
                        InsertTablesWithData(AllDataCategory::MembershipMaster);
                        //-NPR5.51 [319037]
                    end;
                }
            }
            group(IncludingTransactions)
            {
                Caption = 'Including Transactions';
                Image = Data;
                action(IncludeStdRetailData)
                {
                    Caption = 'Add Std and Retail Data Incl. Transactions';
                    Image = Default;

                    trigger OnAction()
                    begin
                        //-NPR5.40 [309303]
                        // All Std and Retail Tables including Transactions
                        InsertTablesWithData(AllDataCategory::"Std and Retail");
                        //+NPR5.40 [309303]
                    end;
                }
                action(IncludeStdOnlyTables)
                {
                    Caption = 'Add Std. Nav. Tables Incl. Transactions';
                    Image = Default;

                    trigger OnAction()
                    begin
                        //-NPR5.40 [309303]
                        // All Std Nav Tables including Transactions
                        InsertTablesWithData(AllDataCategory::"All Std");
                        //+NPR5.40 [309303]
                    end;
                }
                action(IncludeAllDataTables)
                {
                    Caption = 'Add All Trans. Tables Excl. Ticket';
                    Image = Default;

                    trigger OnAction()
                    begin
                        //-NPR5.40 [309303]
                        //InsertTablesWithData();
                        InsertTablesWithData(AllDataCategory::All);
                        //+NPR5.40 [309303]
                    end;
                }
                action(IncludeNPAddOnsTables)
                {
                    Caption = 'Add NP Add-On Tables Incl. Transactions';
                    Image = Default;
                    Visible = false;

                    trigger OnAction()
                    begin
                        //-NPR5.40 [309303]
                        // Add-ons Tables including Transactions
                        InsertTablesWithData(AllDataCategory::"All NPAdd-Ons");
                        //+NPR5.40 [309303]
                    end;
                }
                action(IncludeRetailTables)
                {
                    Caption = 'Add Retail Tables Incl.Transactions';
                    Image = Default;
                    Visible = false;

                    trigger OnAction()
                    begin
                        //-NPR5.40 [309303]
                        // All Retail Tables including Transactions
                        InsertTablesWithData(AllDataCategory::"All Retail");
                        //+NPR5.40 [309303]
                    end;
                }
                action(TicketingTransactionTables)
                {
                    Caption = 'Add Ticketing Tables Incl. Transaction';
                    Image = Default;

                    trigger OnAction()
                    begin
                        //-NPR5.51 [319037]
                        InsertTablesWithData(AllDataCategory::TicketingTransactional);
                        //+NPR5.51 [319037]
                    end;
                }
            }
            group(ExportDemoData)
            {
                Caption = 'Export Demo Data';
                action(Standard)
                {
                    Caption = 'Standard';
                    Image = Default;

                    trigger OnAction()
                    var
                        Obj: Record AllObj;
                        Total: Integer;
                        TestOnCRM: Boolean;
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        "Count": Integer;
                        RecRef: RecordRef;
                        Dia: Dialog;
                    begin
                        //-NPR5.44 [322867]
                        Dia.Open(Text00001);
                        Obj.SetRange("Object Type", Obj."Object Type"::Table);

                        Obj.SetFilter("Object ID", '%1..%2|%3..%4|%5..%6', 1, 49999, 199999, 11102034, 11102199, 2000000000); //Exclude Customer, OMA and Std NAV tables above 2000000000
                        Total := Obj.Count;
                        TestOnCRM := not CRMIntegrationManagement.IsCRMIntegrationEnabled;

                        if Obj.FindSet then
                            repeat
                                Count += 1;
                                Dia.Update(1, Obj."Object ID");
                                Dia.Update(2, Round(Count / Total * 10000, 1));
                                if not (IsEntryTable(Obj."Object ID") or
                                        IsJournalTable(Obj."Object ID") or
                                        IsPostedDocument(Obj."Object ID") or
                                        IsOpenDocument(Obj."Object ID") or
                                        IsPepperTable(Obj."Object ID") or
                                        IsMustAvoidTable(Obj."Object ID")) then begin
                                    if CheckTablePermissions(Obj."Object ID") and not SkipCRMTable(Obj."Object ID", TestOnCRM) then begin
                                        //-NPR5.48 [340086]
                                        //      RecRef.OPEN(Obj."Object ID");
                                        //      IF NOT RecRef.ISEMPTY THEN
                                        //        AddTable(Obj."Object ID");
                                        //      RecRef.CLOSE;
                                        AddTable(Obj."Object ID");
                                        //+NPR5.48 [340086]
                                    end;
                                end;
                            until Obj.Next = 0;
                        Dia.Close;
                        //+NPR5.44 [322867]
                    end;
                }
                action(AddPepper)
                {
                    Caption = 'Add Pepper';
                    Image = Add;

                    trigger OnAction()
                    var
                        Obj: Record AllObj;
                        Total: Integer;
                        "Count": Integer;
                        RecRef: RecordRef;
                        Dia: Dialog;
                    begin
                        //-NPR5.45 [322867]
                        Dia.Open(Text00001);
                        Obj.SetRange("Object Type", Obj."Object Type"::Table);

                        Obj.SetFilter("Object ID", '%1..%2', 1, 2000000000);
                        Total := Obj.Count;
                        if Obj.FindSet then
                            repeat
                                Count += 1;
                                Dia.Update(1, Obj."Object ID");
                                Dia.Update(2, Round(Count / Total * 10000, 1));
                                if IsPepperTable(Obj."Object ID") then begin
                                    //-NPR5.48 [340086]
                                    //    RecRef.OPEN(Obj."Object ID");
                                    //    IF NOT RecRef.ISEMPTY THEN
                                    //      AddTable(Obj."Object ID");
                                    //    RecRef.CLOSE;
                                    AddTable(Obj."Object ID");
                                    //+NPR5.48 [340086]
                                end;
                            until Obj.Next = 0;
                        Dia.Close;
                        //+NPR5.45 [322867]
                    end;
                }
            }
        }
        area(navigation)
        {
            group(OtherDataFunctions)
            {
                Caption = 'OtherDataFunctions';
                action(IncludeMasterData)
                {
                    Caption = 'Include Offline Master Data Template';
                    Enabled = false;
                    Image = DataEntry;

                    trigger OnAction()
                    begin
                        InsertOfflineSetup();
                    end;
                }
                action(IncludeWebData)
                {
                    Caption = 'Insert Webshop Base Setup';
                    Enabled = false;
                    Image = Web;

                    trigger OnAction()
                    begin
                        InsertWebshopSetup();
                    end;
                }
                action(IncludeBaseData)
                {
                    Caption = 'Include Base Setup';
                    Image = Default;

                    trigger OnAction()
                    begin
                        InsertBaseSetup();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-234161
        //CurrPage.TableFilters.PAGE.SetSourceTable('',"Object ID",'')
        //+234161
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        //-NPR5.23
        CurrPage.Fields.PAGE.ClearData();
        CurrPage.TableFilters.PAGE.ClearData();
        exit(Delete);
        //+NPR5.23
    end;

    trigger OnOpenPage()
    begin
        SetDefaultVars;
        CurrPage.Update(false);
    end;

    var
        TableExportLibrary: Codeunit "Table Export Library";
        "--- Input Vars ---": Integer;
        UseCompanyName: Text[50];
        FileName: Text[250];
        FieldStartDelimeter: Text[10];
        FieldEndDelimeter: Text[10];
        FieldSeparator: Text[10];
        RaiseErrors: Boolean;
        RecordSeparator: Text[30];
        DataItemSeparator: Text[30];
        ShowStatus: Boolean;
        WriteFieldHeader: Boolean;
        WriteTableInformation: Boolean;
        SkipFlowFields: Boolean;
        OutFileEncoding: Text[30];
        FileMode: Option OStream,,DotNetStream;
        TrimSpecialChars: Boolean;
        Text00001: Label '#1############\@2@@@@@@@@@@@@';
        AllDataCategory: Option All,"All Std","All Retail","Std and Retail","All NPAdd-Ons","All Master","Std Master","Retail Master","StdRetail Master",TicketingSetupMaster,TicketingTransactional,MembershipMaster;
        ExportDataInXmlFormat: Boolean;
        EscapeCharacter: Text[1];

    procedure AddField(TableID: Integer; FieldNo: Integer)
    begin
        CurrPage.Fields.PAGE.AddField(TableID, FieldNo);
    end;

    procedure AddTable(TableID: Integer)
    var
        AllObj: Record AllObj;
        RecRef: RecordRef;
    begin
        //-NPR5.48 [340086]
        RecRef.Open(TableID);
        if RecRef.IsEmpty then
            exit;
        //+NPR5.48 [340086]

        Init;
        //-NPR5.23
        if AllObj.Get(AllObj."Object Type"::Table, TableID) then begin
            TransferFields(AllObj);
            //+NPR5.23
            if Insert then;
            //-NPR5.48 [340086]
            AddTableFields(TableID);
            //+NPR5.48 [340086]
        end;
    end;

    local procedure AddTableFields(TableID: Integer)
    var
        "Field": Record "Field";
    begin
        //-NPR5.48 [340086]
        Field.SetRange(TableNo, TableID);
        Field.SetRange(Enabled, true);
        //-NPR5.53 [382903]
        Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
        //-NPR5.53 [382903]
        if SkipFlowFields then
            Field.SetRange(Class, Field.Class::Normal)
        else
            Field.SetRange(Class, Field.Class::Normal, Field.Class::FlowField);

        if Field.FindSet then
            repeat
                AddField(TableID, Field."No.");
            until Field.Next = 0;
        //+NPR5.48 [340086]
    end;

    procedure ClearTableInfo()
    begin
        DeleteAll;
        CurrPage.Fields.PAGE.ClearAllData();
        //-NPR5.23
        CurrPage.TableFilters.PAGE.ClearAllData();
        //+NPR5.23
    end;

    procedure InsertOfflineSetup()
    begin
        //-NPR5.33 [280329]
        Error('This function is discontinued 01-07-2017. Please contact Navipartner if this is a function you use');
        // ClearTableInfo();
        // AddTable(DATABASE::Item);
        // AddField(DATABASE::Item,Item.FIELDNO("No."));
        // AddField(DATABASE::Item,Item.FIELDNO(Description));
        // AddField(DATABASE::Item,Item.FIELDNO("Search Description"));
        // AddField(DATABASE::Item,Item.FIELDNO("Base Unit of Measure"));
        // AddField(DATABASE::Item,Item.FIELDNO("Inventory Posting Group"));
        // AddField(DATABASE::Item,Item.FIELDNO("Item Disc. Group"));
        // AddField(DATABASE::Item,Item.FIELDNO("Item Group"));
        // AddField(DATABASE::Item,Item.FIELDNO("Unit Price"));
        // AddField(DATABASE::Item,Item.FIELDNO("Unit Cost"));
        // AddField(DATABASE::Item,Item.FIELDNO("VAT Bus. Posting Gr. (Price)"));
        // AddField(DATABASE::Item,Item.FIELDNO("Gen. Prod. Posting Group"));
        // AddField(DATABASE::Item,Item.FIELDNO("Group sale"));
        // AddField(DATABASE::Item,Item.FIELDNO("Price Includes VAT"));
        // AddField(DATABASE::Item,Item.FIELDNO("VAT Prod. Posting Group"));
        // AddTable(DATABASE::"BOM Component");
        // AddTable(DATABASE::"No. Series");
        // AddTable(DATABASE::"No. Series Line");
        // AddTable(DATABASE::Dimension);
        // AddTable(DATABASE::"Dimension Value");
        // AddTable(DATABASE::"Dimension Translation");
        // AddTable(DATABASE::"Retail Contract Setup");
        // AddTable(DATABASE::"Customer Posting Group");
        // AddTable(DATABASE::"Vendor Posting Group");
        // AddTable(DATABASE::"Inventory Posting Group");
        // AddTable(DATABASE::"Gen. Business Posting Group");
        // AddTable(DATABASE::"Gen. Product Posting Group");
        // AddTable(DATABASE::"General Posting Setup");
        // AddTable(DATABASE::"Bank Account Posting Group");
        // AddTable(DATABASE::"VAT Business Posting Group");
        // AddTable(DATABASE::"VAT Product Posting Group");
        // AddTable(DATABASE::"VAT Posting Setup");
        // AddTable(DATABASE::"Retail Setup");
        // AddTable(DATABASE::"Item Group");
        // AddTable(DATABASE::"Customer Price Group");
        // AddTable(DATABASE::"Salesperson/Purchaser");
        // AddTable(DATABASE::"G/L Account");
        // AddTable(DATABASE::"Alternative No.");
        // AddTable(DATABASE::"Report Selections");
        // AddTable(DATABASE::"Company Information");
        // AddTable(DATABASE::"Inventory Posting Group");
        // AddTable(DATABASE::"Unit of Measure");
        // AddTable(DATABASE::"Source Code");
        // AddTable(DATABASE::"Bank Account");
        // AddTable(DATABASE::"Item Variant");
        // AddTable(DATABASE::"Item Unit of Measure");
        // AddTable(DATABASE::"Retail Setup");
        // AddTable(DATABASE::Register);
        // AddTable(DATABASE::"Payment Type POS");
        // AddTable(DATABASE::"Report Selection Retail");
        // AddTable(DATABASE::"Mixed Discount");
        // AddTable(DATABASE::"Mixed Discount Line");
        // AddTable(DATABASE::"Period Discount");
        // AddTable(DATABASE::"Period Discount Line");
        // AddTable(DATABASE::"Quantity Discount Line");
        // AddTable(DATABASE::"Discount Priority");
        // AddTable(DATABASE::"Payment Type - Prefix");
        // AddTable(DATABASE::"Touch Screen - Menu Lines");
        // AddTable(DATABASE::"Touch Screen - Meta Functions");
        // AddTable(DATABASE::"Payment Type - Detailed");
        // AddTable(DATABASE::Properties);
        // AddTable(DATABASE::"Quantity Discount Header");
        // AddTable(DATABASE::"Touch Screen - Menu Lines");
        // AddTable(DATABASE::"Touch Screen - MetaTriggers");
        // //-NPR5.23
        // // AddTable(DATABASE::"Color Management");
        // // AddTable(DATABASE::"Size Management");
        // // AddTable(DATABASE::"Variance Set Up");
        // // AddTable(DATABASE::"Variance Sizes");
        // // AddTable(DATABASE::"Variance Colors");
        // // AddTable(DATABASE::"VariaX Dim. Setup");
        // // AddTable(DATABASE::"VariaX Dim. Values");
        // // AddTable(DATABASE::"VariaX Dim. Combination");
        // // AddTable(DATABASE::"VariaX Fixed Item Dimensions");
        // // AddTable(DATABASE::"VariaX Variant Info");
        // // AddTable(DATABASE::"VariaX Configuration");
        // //+NPR5.23
        // AddTable(DATABASE::"Printer Selection");
        // AddTable(DATABASE::"Report Selection Retail");
        //
        // CurrPage.UPDATE(FALSE);
        //+NPR5.33 [280329]
    end;

    procedure InsertStdSetupTables()
    var
        "Object": Record "Object";
        AllObj: Record AllObj;
    begin
        //-NPR5.46 [322752]
        // Object.SETRANGE(Type,Object.Type::Table);
        // Object.SETRANGE(ID,1,49999);
        // Object.SETFILTER(Name,'%1','*Setup');
        // IF Object.FINDSET THEN REPEAT
        //  AddTable(Object.ID)
        // UNTIL Object.NEXT = 0;

        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        AllObj.SetRange("Object ID", 1, 49999);
        AllObj.SetFilter("Object Name", '%1', '*Setup');
        if AllObj.FindSet then
            repeat
                AddTable(AllObj."Object Type")
until AllObj.Next = 0;
        //+NPR5.46 [322752]
    end;

    procedure InsertBaseSetup()
    var
        Item: Record Item;
    begin
        InsertStdSetupTables();
        AddTable(DATABASE::Item);
        AddTable(DATABASE::"Payment Terms");
        AddTable(DATABASE::Currency);
        AddTable(DATABASE::"Customer Price Group");
        AddTable(DATABASE::"Standard Text");
        AddTable(DATABASE::"Country/Region");
        AddTable(DATABASE::"Salesperson/Purchaser");
        AddTable(DATABASE::Location);
        AddTable(DATABASE::"G/L Account");
        AddTable(DATABASE::"Accounting Period");
        AddTable(DATABASE::"Report Selections");
        AddTable(DATABASE::"Company Information");
        AddTable(DATABASE::"Gen. Journal Template");
        AddTable(DATABASE::"User Setup");
        AddTable(DATABASE::"Customer Posting Group");
        AddTable(DATABASE::"Vendor Posting Group");
        AddTable(DATABASE::"Inventory Posting Group");
        AddTable(DATABASE::"G/L Budget Name");
        AddTable(DATABASE::"General Ledger Setup");
        AddTable(DATABASE::"Unit of Measure");
        AddTable(DATABASE::"Post Code");
        AddTable(DATABASE::"Source Code");
        AddTable(DATABASE::"Source Code Setup");
        AddTable(DATABASE::"Gen. Business Posting Group");
        AddTable(DATABASE::"Gen. Product Posting Group");
        AddTable(DATABASE::"General Posting Setup");
        AddTable(DATABASE::"VAT Statement Template");
        AddTable(DATABASE::"VAT Statement Name");
        AddTable(DATABASE::"No. Series");
        AddTable(DATABASE::"No. Series Line");
        AddTable(DATABASE::"Sales & Receivables Setup");
        AddTable(DATABASE::"Purchases & Payables Setup");
        AddTable(DATABASE::"Inventory Setup");
        AddTable(DATABASE::"Resources Setup");
        AddTable(DATABASE::"Jobs Setup");
        AddTable(DATABASE::"VAT Business Posting Group");
        AddTable(DATABASE::"VAT Product Posting Group");
        AddTable(DATABASE::"VAT Posting Setup");
        AddTable(DATABASE::"Currency Exchange Rate");
        AddTable(DATABASE::"Column Layout Name");
        AddTable(DATABASE::"Customer Discount Group");
        AddTable(DATABASE::Dimension);
        AddTable(DATABASE::"Change Log Setup");
        //-NPR5.20
        //AddTable(DATABASE::Table465);
        //+NPR5.20
        AddTable(DATABASE::"Contact Business Relation");
        AddTable(DATABASE::"Interaction Template");
        AddTable(DATABASE::"Segment Header");
        AddTable(DATABASE::"Marketing Setup");
        AddTable(DATABASE::"Customer Template");
        AddTable(DATABASE::"Interaction Template Setup");
        AddTable(DATABASE::"Human Resources Setup");
        AddTable(DATABASE::"FA Setup");
        AddTable(DATABASE::"Nonstock Item Setup");
        AddTable(DATABASE::"Warehouse Setup");
        AddTable(DATABASE::"Inventory Posting Setup");
        AddTable(DATABASE::"Service Mgt. Setup");
        AddTable(DATABASE::"Retail Setup");
        AddTable(DATABASE::Register);
        AddTable(DATABASE::"Payment Type POS");
        AddTable(DATABASE::"Report Selection Retail");
        AddTable(DATABASE::"Item Group");
        AddTable(DATABASE::"Audit Roll Posting");
        AddTable(DATABASE::"Retail Document Header");
        AddTable(DATABASE::"Retail Document Lines");
        AddTable(DATABASE::"Payment Type - Prefix");
        AddTable(DATABASE::"E-mail Log");
        AddTable(DATABASE::"E-mail Template Header");
        AddTable(DATABASE::"E-mail Template Line");
        AddTable(DATABASE::"I-Comm");
        AddTable(DATABASE::"Retail Contract Setup");
        //-NPR5.23
        //AddTable(DATABASE::"NAS - Tasks");
        //AddTable(DATABASE::"DBI - Field Filters");
        //+NPR5.23
        AddTable(DATABASE::"Manufacturing Setup");
        AddTable(DATABASE::"Order Promising Setup");
        //-NPR5.25
        AddTable(DATABASE::"Object Output Selection");
        AddTable(DATABASE::"RP Template Header");
        AddTable(DATABASE::"RP Template Line");
        AddTable(DATABASE::"RP Data Items");
        AddTable(DATABASE::"RP Data Item Links");
        //+NPR5.25
        //-NPR5.25
        AddTable(DATABASE::"Pepper EFT Transaction Type");
        AddTable(DATABASE::"Pepper EFT Result Code");
        AddTable(DATABASE::"Pepper Configuration");
        AddTable(DATABASE::"Pepper Instance");
        AddTable(DATABASE::"Pepper Terminal");
        AddTable(DATABASE::"Pepper Terminal Type");
        AddTable(DATABASE::"Pepper Version");
        AddTable(DATABASE::"EFT Transaction Request");
        AddTable(DATABASE::"EFT Transact. Req. Comment");
        AddTable(DATABASE::"Pepper Card Type");
        AddTable(DATABASE::"Pepper Card Type Fee");
        AddTable(DATABASE::"Pepper Card Type Group");
        //+NPR5.25
        //-NPR5.25
        AddTable(DATABASE::"Connection Profile");
        //+NPR5.25
    end;

    procedure InsertWebshopSetup()
    begin
        //-NPR5.33 [280329]
        Error('This function is discontinued 01-07-2017. Please contact Navipartner if this is a function you use');
        // AddTable(DATABASE::"GIM - Document Type");
        // AddTable(DATABASE::"MM Admission Service Setup");
        // AddTable(DATABASE::"MM Admission Service Entry");
        // AddTable(DATABASE::"MM Admission Service Log");
        // AddTable(DATABASE::Table6060093);
        //+NPR5.33 [280329]
    end;

    procedure InsertTablesWithData(AllTransferCategory: Option All,"All Std","All Retail","Std and Retail","All NPAdd-Ons","All Master","Std Master","Retail Master","StdRetail Master",TicketingSetupMaster,TicketingTransactional,MembershipMaster)
    var
        TableInformation: Record "Table Information";
        AllObj: Record AllObj;
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        RecordRef: RecordRef;
        "Count": Integer;
        Total: Integer;
        TestOnCRM: Boolean;
        Window: Dialog;
    begin


        Window.Open(Text00001);
        TableInformation.SetRange("Company Name", UseCompanyName);
        AllObj.SetRange("Object Type", AllObj."Object Type"::Table);
        //-NPR5.40 [309303]
        //AllObj.SETRANGE("Object ID",1,6060100);
        case AllTransferCategory of
            AllTransferCategory::All:
                AllObj.SetRange("Object ID", 1, 9999999);        // All Tables

            AllTransferCategory::"All Std":
                AllObj.SetRange("Object ID", 1, 9999);            // All Std Nav Tables

            AllTransferCategory::"All Retail":
                AllObj.SetRange("Object ID", 6014400, 6189999);     // All Retail Tables

            AllTransferCategory::"Std and Retail":
                AllObj.SetRange("Object ID", 1, 6189999);          // All Std and Retail Tables

            AllTransferCategory::"All NPAdd-Ons":
                AllObj.SetRange("Object ID", 6059767, 6060166);   // Add-ons Tables

            AllTransferCategory::"All Master":
                AllObj.SetRange("Object ID", 1, 9999999);        // All Master and Setup Tables

            AllTransferCategory::"Std Master":
                AllObj.SetRange("Object ID", 1, 9999);           // Std Master and Setup Tables

            AllTransferCategory::"Retail Master":
                AllObj.SetRange("Object ID", 6014400, 6189999);  // Retail Master And Setup

            AllTransferCategory::"StdRetail Master":
                AllObj.SetRange("Object ID", 1, 6189999);        // Std and Retail Master and Setup tables
          //-NPR5.51 [319037]
          AllTransferCategory::TicketingSetupMaster : AllObj.SetFilter("Object ID",'%1|%2|%3|%4|%5',6060118,6060119,6060120,6060121,6059784);        // Ticketing Master and Setup Tables
          AllTransferCategory::TicketingTransactional : AllObj.SetFilter("Object ID",'%1|%2|%3|%4|%5|%6|%7',6060111,6060113,6060110,6059785,6059786,6059787,6059788);  // Ticketing Transaction Tables
          AllTransferCategory::MembershipMaster : AllObj.SetFilter("Object ID",'%1|%2|%3|%4|%5|%6|%7',6060124,6060125,6060140,6060141,6060142,6060132,6060136);  // Membership Master and Setup Tables
          //+NPR5.51 [319037]
        end;
        //+NPR5.40 [309303]

        Total := AllObj.Count;
        TestOnCRM := not CRMIntegrationManagement.IsCRMIntegrationEnabled;

        if AllObj.FindSet then
            repeat
                Count += 1;
          //-NPR5.53 [385785]
          if CheckTablePermissions(AllObj."Object ID") and not SkipCRMTable(AllObj."Object ID",TestOnCRM) and not IsTableObsolete(AllObj."Object ID") then begin
          //+NPR5.53 [385785]
                    RecordRef.Open(AllObj."Object ID");
                    Window.Update(1, AllObj."Object ID");
                    Window.Update(2, Round(Count / Total * 10000, 1));
                    //-NPR5.48 [340086]
                    //IF RecordRef.COUNT > 0 THEN BEGIN
                    //+NPR5.48 [340086]
                    case AllTransferCategory of
              //-NPR5.51 [319037]
              AllTransferCategory::All:
              if AllObj."Object ID" in [6059784..6059786,6060109,6060112,6060114..6060116,6060121,6060123] = false then
                AddTable(AllObj."Object ID");
              //+NPR5.51 [319037]



                        AllTransferCategory::"All Master":         // All Master and Setup Tables except Transactions
                                                                   //-NPR5.41 [311855]
                                                                   //IF AllObj."Object ID" IN [17,32,36,37,45..46,253..254,405,472..481,5802,5811,6014403,6014405..6014407,6150620..6150635,6150698,6150700,6150701,6151504] = FALSE THEN

                            if AllObj."Object ID" in [17, 21, 25, 32 .. 62, 81, 83 .. 91, 95 .. 97, 99 .. 203, 205 .. 224, 240 .. 241, 244 .. 249, 253 .. 269
                              , 271 .. 276, 278 .. 288, 290, 295 .. 307, 317, 330 .. 339, 342 .. 347, 353 .. 1705, 5061 .. 5078, 5093 .. 5104, 5107 .. 5650, 5740 .. 5800
                              , 5802 .. 5811, 5815 .. 6084, 6506 .. 6550, 6650 .. 6670, 7030 .. 6009999
                                , 6014403, 6014405 .. 6014409, 6014411 .. 6014426, 6014429 .. 6014432, 6014434 .. 6014436, 6014439 .. 6014444, 6014445 .. 6014446
                                , 6014449 .. 6014460, 6014473 .. 6014509, 6014552 .. 6014559, 6014561 .. 6014564, 6014628 .. 6014642, 6059768, 6059767
                                  //-NPR5.48 [340086]
                                  //              ,6059770..6059772,6059781..6059782,6059785..6059893,6059898,6059903..6059934,6059940..6059941,6059946,6059951..6059968
                                  //              ,6059970..6060166,6150620..6150699,6150723..6150725,6150901..6184489,6184495..6184496,6184501..6184502,6184510..619999] = FALSE THEN
                                  , 6059770 .. 6059772, 6059781 .. 6059782, 6059785 .. 6059893, 6059898 .. 6059899, 6059903 .. 6059934, 6059940 .. 6059941, 6059946, 6059951 .. 6059968
                                  , 6059970 .. 6060166, 6150620 .. 6150699, 6150723 .. 6150725, 6150901 .. 6184489, 6184495 .. 6184496, 6184501 .. 6184502, 6184510 .. 6189999] = false then
                                //+NPR5.48 [340086]
                                //+NPR5.41 [311855]
                                AddTable(AllObj."Object ID");

                        AllTransferCategory::"Std Master":         // All Std Nav Master And Setup Tables except Transactions
                                                                   //-NPR5.41 [311855]
                                                                   //IF AllObj."Object ID" IN [17,32,36,37,45..46,253..254,405,472..481,5802,5811] = FALSE THEN
                            if AllObj."Object ID" in [17, 21, 25, 32 .. 62, 81, 83 .. 91, 95 .. 97, 99 .. 203, 205 .. 224, 240 .. 241, 244 .. 249, 253 .. 269
                              , 271 .. 276, 278 .. 288, 290, 295 .. 307, 317, 330 .. 339, 342 .. 347, 353 .. 1705, 5061 .. 5078, 5093 .. 5104, 5107 .. 5650, 5740 .. 5800
                              , 5802 .. 5811, 5815 .. 6084, 6506 .. 6550, 6650 .. 6670, 7030 .. 6009999] = false then
                                //+NPR5.41 [311855]
                                AddTable(AllObj."Object ID");

              AllTransferCategory::"Retail Master" : begin      // All Retail Master and Setup Tables except Transactions

                //-NPR5.51 [319037]
                //-NPR5.41 [311855]
                //IF AllObj."Object ID" IN [6014403,6014405..6014407,6150620..6150635,6150698,6150700,6150701,6151504] = FALSE THEN
                //IF AllObj."Object ID" IN [6014403,6014405..6014409,6014411..6014426,6014429..6014432,6014434..6014436,6014439..6014444,6014445..6014446
                    //,6014449..6014460,6014473..6014509,6014552..6014559,6014561..6014564,6014628..6014642,6059768,6059767
        //-NPR5.48 [340086]
        //              ,6059770..6059772,6059781..6059782,6059785..6059893,6059898,6059903..6059934,6059940..6059941,6059946,6059951..6059968
        //              ,6059970..6060166,6150620..6150699,6150723..6150725,6150901..6184489,6184495..6184496,6184501..6184502,6184510..619999] = FALSE THEN
                      //,6059770..6059772,6059781..6059782,6059785..6059893,6059898..6059899,6059903..6059934,6059940..6059941,6059946,6059951..6059968
                      //,6059970..6060166,6150620..6150699,6150723..6150725,6150901..6184489,6184495..6184496,6184501..6184502,6184510..6189999] = FALSE THEN
        //+NPR5.48 [340086]
                //+NPR5.41 [311855]

                if AllObj."Object ID" in [6014403,6014405..6014409,6014411..6014416,6014418..6014426,6014429..6014432,6014434..6014436,6014439..6014444,6014445..6014446
                    ,6014449..6014460,6014473..6014477,6014481..6014509,6014552..6014559,6014561..6014564,6014628..6014642,6059768
                    ,6059770..6059772,6059781..6059782,6059785..6059893,6059898..6059899,6059903..6059934,6059940..6059941,6059946,6059951..6059968
                    ,6059970..6060039,6060042..6060051,6060054,6060056..6060166,6150620..6150639,6150643..6150699,6150723..6150725,6150901..6151010
                    ,6151013..6151099,6151103,6151108..6151124,6151131..6151589,6151591..6151598,6151604..6184489,6184495..6184496,6184501..6184502,6184510..6189999] = false then

                //+NPR5.51 [319037]
                                    AddTable(AllObj."Object ID");

                                //-NPR5.41 [311855]
                                AddTable(308);
                                AddTable(309);
                                AddTable(310);
                //-NPR5.51 [319037]
                AddTable(6150731);
                AddTable(6150732);
                //+NPR5.51 [319037]
                            end;
                            //+NPR5.41 [311855]

              AllTransferCategory::"StdRetail Master" : begin   // Retail Master and Setup Tables except Transactions
                //-NPR5.51 [319037]
                //-NPR5.41 [311855]
                //IF AllObj."Object ID" IN [17,32,36,37,45..46,253..254,405,472..481,5802,5811,6014403,6014405..6014407,6150620..6150635,6150698,6150700,6150701,6151504] = FALSE THEN

                //IF AllObj."Object ID" IN [17,21,25,32..62,81,83..91,95..97,99..203,205..224,240..241,244..249,253..269
                  //,271..276,278..288,290,295..307,317,330..339,342..347,353..1705,5061..5078,5093..5104,5107..5650
                  //,5740..5800,5802..5811,5815..6084,6506..6550,6650..6670,7030..6009999
                    //,6014403,6014405..6014409,6014411..6014426,6014429..6014432,6014434..6014436,6014439..6014444,6014445..6014446
                    //,6014449..6014460,6014473..6014509,6014552..6014559,6014561..6014564,6014628..6014642,6059768,6059767
        //-NPR5.48 [340086]
        //              ,6059770..6059772,6059781..6059782,6059785..6059893,6059898,6059903..6059934,6059940..6059941,6059946,6059951..6059968
        //              ,6059970..6060166,6150620..6150699,6150723..6150725,6150901..6184489,6184495..6184496,6184501..6184502,6184510..619999] = FALSE THEN
                      //,6059770..6059772,6059781..6059782,6059785..6059893,6059898..6059899,6059903..6059934,6059940..6059941,6059946,6059951..6059968
                     // ,6059970..6060166,6150620..6150699,6150723..6150725,6150901..6184489,6184495..6184496,6184501..6184502,6184510..6189999] = FALSE THEN

        //+NPR5.48 [340086]
                //+NPR5.41 [311855]
                if AllObj."Object ID" in [17,21,25,32..62,81,83..91,95..97,99..203,205..224,240..241,244..249,253..269
                                          ,271..276,278..288,290,295..307,317,330..339,342..347,353..1705,5061..5078,5093..5104,5107..5650
                                          ,5740..5800,5802..5811,5815..6084,6506..6550,6650..6670,7030..6009999
                                          ,6014403,6014405..6014409,6014411..6014416,6014418..6014426,6014429..6014432,6014434..6014436,6014439..6014444,6014445..6014446
                                          ,6014449..6014460,6014473..6014477,6014481..6014509,6014552..6014559,6014561..6014564,6014628..6014642,6059768
                                          ,6059770..6059772,6059781..6059782,6059785..6059893,6059898..6059899,6059903..6059934,6059940..6059941,6059946,6059951..6059968
                                          ,6059970..6060039,6060042..6060051,6060054,6060056..6060166,6150620..6150639,6150643..6150699,6150723..6150725,6150901..6151010
                                          ,6151013..6151099,6151103,6151108..6151124,6151131..6151589,6151591..6151598,6151604..6184489,6184495..6184496,6184501..6184502,6184510..6189999] = false then



                //+NPR5.51 [319037]
                                    AddTable(AllObj."Object ID");
                                //-NPR5.41 [311855]
                                AddTable(308);
                                AddTable(309);
                                AddTable(310);
                            end;
                        //+NPR5.41 [311855]

              //-NPR5.51 [319037]
              AllTransferCategory::TicketingSetupMaster: begin
                if AllObj."Object ID" in [6060118,6060119,6060120,6060121,6059784] then
                  AddTable(AllObj."Object ID");
              end;

              AllTransferCategory::TicketingTransactional: begin
                if AllObj."Object ID" in [6059785,6059786,6060109..6060116,6060121,6060123,6059787,6059788] then
                  AddTable(AllObj."Object ID");
              end;

              AllTransferCategory::MembershipMaster: begin
                if AllObj."Object ID" in [6060124,6060125,6060140,6060141,6060142,6060132,6060136] then
                  AddTable(AllObj."Object ID");
              end;
              //-NPR5.51 [319037]

                        else
                            AddTable(AllObj."Object ID");
                    end;
                    //+NPR5.40 [309303]
                    RecordRef.Close;
                end;
            until AllObj.Next = 0;
        Window.Close;
    end;

    procedure RunExport()
    var
        TempField: Record "Field" temporary;
        TempTable: Record AllObj temporary;
        TempTableFilter: Record "Table Filter" temporary;
    begin
        TableExportLibrary.Reset;

        FindSet;
        repeat
            TableExportLibrary.AddTableForExport("Object ID");
        until Next = 0;

        CurrPage.Fields.PAGE.GetFields(TempField);
        if TempField.FindSet then
            repeat
                TableExportLibrary.AddFieldForExport(TempField.TableNo, TempField."No.");
            until TempField.Next = 0;

        //-NPR5.23
        CurrPage.TableFilters.PAGE.GetData(TempTableFilter);
        TableExportLibrary.SetTableFilters(TempTableFilter);
        //+NPR5.23

        if CompanyName <> UseCompanyName then
            TableExportLibrary.SetCompany(UseCompanyName);

        TableExportLibrary.SetRecordSeparator(RecordSeparator);
        TableExportLibrary.SetDataItemSeparator(DataItemSeparator);
        TableExportLibrary.SetFieldStartDelimeter(FieldStartDelimeter);
        TableExportLibrary.SetFieldEndDelimeter(FieldEndDelimeter);
        TableExportLibrary.SetFieldSeparator(FieldSeparator);
        //-NPR5.48 [340086]
        TableExportLibrary.SetEscapeCharacter(EscapeCharacter);
        //+NPR5.48 [340086]

        TableExportLibrary.SetShowStatus(ShowStatus);
        TableExportLibrary.SetWriteFieldHeader(WriteFieldHeader);
        TableExportLibrary.SetWriteTableInformation(WriteTableInformation);
        TableExportLibrary.SetSkipFlowFields(SkipFlowFields);

        TableExportLibrary.SetFileName(FileName);
        TableExportLibrary.SetRaiseErrors(RaiseErrors);
        //-NPR5.41 [308570]
        TableExportLibrary.SetXmlDataFormat(ExportDataInXmlFormat);
        //+NPR5.41 [308570]

        case FileMode of
            //-NPR5.38 [301053]
            // FileMode::ADOStream :
            //  BEGIN
            //    TableExportLibrary.SetFileModeADO;
            //    TableExportLibrary.SetOutFileEncoding(OutFileEncoding);
            //  END;
            //+NPR5.38 [301053]
            FileMode::OStream:
                TableExportLibrary.SetFileModeOStream;
            FileMode::DotNetStream:
                begin
                    TableExportLibrary.SetFileModeDotNetStream;
                    TableExportLibrary.SetOutFileEncoding(OutFileEncoding);
                end;
        end;

        TableExportLibrary.SetTrimSpecialChars(TrimSpecialChars);
        TableExportLibrary.ExportTableBatch;
        TableExportLibrary.Reset;

        CurrPage.Update(false);
    end;

    procedure SetDefaultVars()
    begin
        UseCompanyName := CompanyName;
        FileName := '';
        //-NPR5.48 [340086]
        // FieldStartDelimeter   := '"';
        // FieldEndDelimeter     := '"';
        // FieldSeparator        := ';';
        FieldStartDelimeter := '';
        FieldEndDelimeter := '';
        FieldSeparator := '|';
        //+NPR5.48 [340086]
        RaiseErrors := true;
        RecordSeparator := '<NEWLINE>';
        DataItemSeparator := '<NEWLINE><NEWLINE>';
        SkipFlowFields := true;
        ShowStatus := true;
        WriteFieldHeader := false;
        WriteTableInformation := true;
        OutFileEncoding := 'utf-8';
        FileMode := FileMode::DotNetStream;
        TrimSpecialChars := false;
        //-NPR5.41 [308570]
        ExportDataInXmlFormat := true;
        //+NPR5.41 [308570]
        //-NPR5.48 [340086]
        EscapeCharacter := '\';
        //+NPR5.48 [340086]
    end;

    local procedure CheckTablePermissions(TableNo: Integer): Boolean
    var
        LicensePermission: Record "License Permission";
    begin
        //-NPR5.20
        LicensePermission.SetRange("Object Number", TableNo);
        LicensePermission.SetRange("Object Type", LicensePermission."Object Type"::TableData);
        if LicensePermission.FindFirst and (LicensePermission."Read Permission" = LicensePermission."Read Permission"::Yes) then
            exit(true)
        else
            exit(false);
        //+NPR5.20
    end;

    local procedure SaveSetup()
    var
        SavedExportWizard: Record "Saved Export Wizard";
        TempField: Record "Field" temporary;
        TempTableFilter: Record "Table Filter" temporary;
    begin
        //-NPR5.23
        CurrPage.Fields.PAGE.GetFields(TempField);
        CurrPage.TableFilters.PAGE.GetData(TempTableFilter);
        SavedExportWizard.SaveSetup(Rec, TempField, TempTableFilter, UseCompanyName, FileName, FieldStartDelimeter, FieldEndDelimeter,
                                    FieldSeparator, RaiseErrors, RecordSeparator, DataItemSeparator, ShowStatus, WriteFieldHeader,
        //-NPR5.41 [308570]
                                    WriteTableInformation, SkipFlowFields, OutFileEncoding, FileMode, TrimSpecialChars, ExportDataInXmlFormat);
        //+NPR5.41 [308570]
        //+NPR5.23
    end;

    local procedure LoadSetup()
    var
        SavedExportWizard: Record "Saved Export Wizard";
        TempTable: Record AllObj temporary;
        TempField: Record "Field" temporary;
        TempTableFilter: Record "Table Filter" temporary;
    begin
        //-NPR5.23
        SavedExportWizard.LoadSetup(TempTable, TempField, TempTableFilter, UseCompanyName, FileName, FieldStartDelimeter, FieldEndDelimeter,
                                    FieldSeparator, RaiseErrors, RecordSeparator, DataItemSeparator, ShowStatus, WriteFieldHeader,
        //-NPR5.41 [308570]
                                    WriteTableInformation, SkipFlowFields, OutFileEncoding, FileMode, TrimSpecialChars, ExportDataInXmlFormat);
        //+NPR5.41 [308570]
        DeleteAll;
        CurrPage.Fields.PAGE.ClearAllData();
        if TempTable.FindSet then
            repeat
                AddTable(TempTable."Object ID");
            until TempTable.Next = 0;

        if TempField.FindSet then
            repeat
                AddField(TempField.TableNo, TempField."No.");
            until TempField.Next = 0;
        CurrPage.TableFilters.PAGE.ClearAllData();
        CurrPage.TableFilters.PAGE.AddData(TempTableFilter);
        if FindFirst then;
        //+NPR5.23
    end;

    local procedure SkipCRMTable(TableNo: Integer; DoTest: Boolean): Boolean
    var
        "Object": Record "Object";
        TableMetadata: Record "Table Metadata";
    begin
        //-NPR5.38 [297216]
        //-NPR5.40 [306844]
        //IF TableNo IN [6700..6712,6721] THEN
        if TableNo in [6700 .. 6712, 6721, 2162 .. 2200, 5300 .. 5311, 5320 .. 5331, 5450 .. 5456, 6150704, 6014623, 6150713, 6150714, 6150703] then
            exit(true);
        //+NPR5.40 [306844]
        //+NPR5.38 [297216]

        //-NPR5.23
        if not DoTest then
            exit(false);
        if TableMetadata.Get(TableNo) then
            exit(TableMetadata.TableType = TableMetadata.TableType::CRM);
        //+NPR5.23
    end;

    local procedure IsEntryTable(TableNo: Integer): Boolean
    begin
        //-NPR5.44 [322867]
        exit(TableNo in [
        //Entry Tables
        17,//G/L Entry
        21,//Cust. Ledger Entry
        25,//Vendor Ledger Entry
        32,//Item Ledger Entry
        96,//G/L Budget Entry
        160,//Res. Capacity Entry
        169,//Job Ledger Entry
        179,//Reversal Entry
        203,//Res. Ledger Entry
        253,//G/L Entry - VAT Entry Link
        254,//VAT Entry
        265,//Document Entry
        271,//Bank Account Ledger Entry
        272,//Check Ledger Entry
        281,//Phys. Inventory Ledger Entry
        300,//Reminder/Fin. Charge Entry
        317,//Payable Vendor Ledger Entry
        337,//Reservation Entry
        338,//Entry Summary
        339,//Item Application Entry
        343,//Item Application Entry History
        365,//Analysis View Entry
        366,//Analysis View Budget Entry
        379,//Detailed Cust. Ledg. Entry
        380,//Detailed Vendor Ledg. Entry
        405,//Change Log Entry
        454,//Approval Entry
        456,//Posted Approval Entry
        458,//Overdue Approval Entry
        472,//Job Queue Entry
        474,//Job Queue Log Entry
        480,//Dimension Set Entry
        552,//VAT Rate Change Log Entry
        847,//Cash Flow Forecast Entry
        958,//Time Sheet Posting Entry
        1004,//Job WIP Entry
        1005,//Job WIP G/L Entry
        1015,//Job Entry No.
        1104,//Cost Entry
        1109,//Cost Budget Entry
        1206,//Credit Transfer Entry
        1208,//Direct Debit Collection Entry
        1231,//Positive Pay Entry
        1232,//Positive Pay Entry Detail
        1294,//Applied Payment Entry
        1511,//Notification Entry
        1514,//Sent Notification Entry
        5065,//Interaction Log Entry
        5072,//Campaign Entry
        5093,//Opportunity Entry
        5123,//Inter. Log Entry Comment Line
        5601,//FA Ledger Entry
        5625,//Maintenance Ledger Entry
        5629,//Ins. Coverage Ledger Entry
        5802,//Value Entry
        5804,//Avg. Cost Adjmt. Entry Point
        5811,//Post Value Entry to G/L
        5815,//Inventory Period Entry
        5832,//Capacity Ledger Entry
        5846,//Inventory Report Entry
        5896,//Inventory Adjmt. Entry (Order)
        5907,//Service Ledger Entry
        5908,//Warranty Ledger Entry
        5914,//Loaner Entry
        5969,//Contract Gain/Loss Entry
        6507,//Item Entry Relation
        6508,//Value Entry Relation
        6509,//Whse. Item Entry Relation
        7134,//Item Budget Entry
        7154,//Item Analysis View Entry
        7156,//Item Analysis View Budg. Entry
        7312,//Warehouse Entry
        7603,//Customized Calendar Entry
        6014476,//Retail Price Log Entry
        6014508,//Accessory Unfold Entry
        6059768,//NaviDocs Entry
        6059769,//NaviDocs Entry Comment
        6059786,//TM Ticket Access Entry
        6059898,//Data Log Record
        6059899,//Data Log Field
        6059904,//Task Log (Task)
        6059908,//Session Log
        6059944,//NaviDocs Entry Attachment
        6060083,//MCS Recommendations Log
        6060091,//MM Admission Service Entry
        6060122,//TM Admission Schedule Entry
        6060123,//TM Det. Ticket Access Entry
        6060129,//MM Membership Entry
        6060130,//MM Membership Points Entry
        6060139,//MM Member Notification Entry
        6060145,//MM Member Arrival Log Entry
        6060159,//Event Attribute Entry
        6060161,//Event Exch. Int. Temp. Entry
        6150621,//POS Entry
        6150625,//POS Bin Entry
        6150626,//POS Entry Comment Line
        6150631,//#DELETE - Retail Voucher Entry
        6150636,//POS Entry Output Log
        6150647,//POS Info POS Entry
        6150698,//Audit Roll to POS Entry Link
        6150699,//Data Model Upgrade Log Entry
        6151014,//NpRv Voucher Entry
        6151019,//NpRv Arch. Voucher Entry
        6151086,//RIS Retail Inventory Set Entry
        6151504,//Nc Import Entry
        6151559,//NpXml Template Archive
        6151560,//NpXml Template History
        6151592,//NpDc Coupon Entry
        6151598,//NpDc Arch. Coupon Entry
        6184601,//Consignor Entry
        99000757,//Calendar Entry
        99000760,//Calendar Absence Entry
        99000789,//Production Matrix  BOM Entry
        99000799,//Order Tracking Entry
        99000849,//Action Message Entry
        99000852,//Production Forecast Entry
        //Register tables
        45,//G/L Register
        46,//Item Register
        51,//User Time Register
        87,//Date Compr. Register
        240,//Resource Register
        241,//Job Register
        1105,//Cost Register
        1111,//Cost Budget Register
        1205,//Credit Transfer Register
        5617,//FA Register
        5636,//Insurance Register
        5772,//Registered Whse. Activity Hdr.
        5773,//Registered Whse. Activity Line
        5934,//Service Register
        5936,//Service Document Register
        7313,//Warehouse Register
        7344,//Registered Invt. Movement Hdr.
        7345,//Registered Invt. Movement Line
        6060045,//Registered Item Worksheet
        6060046,//Registered Item Worksheet Line
        6150620,//POS Period Register
        6150902,//HC Register
        6184503//CleanCash Register
        ]);
        //+NPR5.44 [322867]
    end;

    local procedure IsJournalTable(TableNo: Integer): Boolean
    begin
        //-NPR5.44 [322867]
        exit(TableNo in [
        80,//Gen. Journal Template
        81,//Gen. Journal Line
        82,//Item Journal Template
        83,//Item Journal Line
        206,//Res. Journal Template
        207,//Res. Journal Line
        209,//Job Journal Template
        210,//Job Journal Line
        232,//Gen. Journal Batch
        233,//Item Journal Batch
        236,//Res. Journal Batch
        237,//Job Journal Batch
        278,//Job Journal Quantity
        750,//Standard General Journal
        751,//Standard General Journal Line
        752,//Standard Item Journal
        753,//Standard Item Journal Line
        1100,//Cost Journal Template
        1101,//Cost Journal Line
        1102,//Cost Journal Batch
        1615,//Office Job Journal
        5605,//FA Journal Setup
        5619,//FA Journal Template
        5620,//FA Journal Batch
        5621,//FA Journal Line
        5622,//FA Reclass. Journal Template
        5623,//FA Reclass. Journal Batch
        5624,//FA Reclass. Journal Line
        5633,//Insurance Journal Template
        5634,//Insurance Journal Batch
        5635,//Insurance Journal Line
        7309,//Warehouse Journal Template
        7310,//Warehouse Journal Batch
        7311,//Warehouse Journal Line
        6014422,//Retail Journal Line
        6014451,//Retail Journal Header
        6014505//Customer Repair Journal
        ]);
        //+NPR5.44 [322867]
    end;

    local procedure IsPostedDocument(TableNo: Integer): Boolean
    begin
        //-NPR5.44 [322867]
        exit(TableNo in [
        110,//Sales Shipment Header
        111,//Sales Shipment Line
        112,//Sales Invoice Header
        113,//Sales Invoice Line
        114,//Sales Cr.Memo Header
        115,//Sales Cr.Memo Line
        120,//Purch. Rcpt. Header
        121,//Purch. Rcpt. Line
        122,//Purch. Inv. Header
        123,//Purch. Inv. Line
        125,//Purch. Cr. Memo Line
        297,//Issued Reminder Header
        298,//Issued Reminder Line
        304,//Issued Fin. Charge Memo Header
        305,//Issued Fin. Charge Memo Line
        430,//Handled IC Outbox Sales Header
        431,//Handled IC Outbox Sales Line
        433,//Handled IC Outbox Purch. Line
        438,//Handled IC Inbox Sales Header
        439,//Handled IC Inbox Sales Line
        440,//Handled IC Inbox Purch. Header
        441,//Handled IC Inbox Purch. Line
        910,//Posted Assembly Header
        911,//Posted Assembly Line
        954,//Time Sheet Header Archive
        955,//Time Sheet Line Archive
        957,//Time Sheet Cmt. Line Archive
        1704,//Posted Deferral Header
        1705,//Posted Deferral Line
        5107,//Sales Header Archive
        5108,//Sales Line Archive
        5109,//Purchase Header Archive
        5110,//Purchase Line Archive
        5125,//Purch. Comment Line Archive
        5126,//Sales Comment Line Archive
        5127,//Deferral Header Archive
        5128,//Deferral Line Archive
        5744,//Transfer Shipment Header
        5745,//Transfer Shipment Line
        5746,//Transfer Receipt Header
        5747,//Transfer Receipt Line
        5970,//Filed Service Contract Header
        5971,//Filed Contract Line
        5989,//Service Shipment Item Line
        5990,//Service Shipment Header
        5991,//Service Shipment Line
        5992,//Service Invoice Header
        5993,//Service Invoice Line
        5994,//Service Cr.Memo Header
        5995,//Service Cr.Memo Line
        6650,//Return Shipment Header
        6651,//Return Shipment Line
        6660,//Return Receipt Header
        6661,//Return Receipt Line
        7318,//Posted Whse. Receipt Header
        7319,//Posted Whse. Receipt Line
        7322,//Posted Whse. Shipment Header
        7323,//Posted Whse. Shipment Line
        7340,//Posted Invt. Put-away Header
        7341,//Posted Invt. Put-away Line
        7342,//Posted Invt. Pick Header
        7343,//Posted Invt. Pick Line
        6014407,//Audit Roll
        6150622,//POS Sales Line
        6150623,//POS Payment Line
        6150624,//POS Balancing Line
        6150626,//POS Entry Comment Line
        6150629//POS Tax Amount Line
        ]);
        //+NPR5.44 [322867]
    end;

    local procedure IsOpenDocument(TableNo: Integer): Boolean
    begin
        //-NPR5.44 [322867]
        exit(TableNo in [
        36,//Sales Header
        37,//Sales Line
        38,//Purchase Header
        39,//Purchase Line
        43,//Purch. Comment Line
        44,//Sales Comment Line
        171,//Standard Sales Line
        174,//Standard Purchase Line
        295,//Reminder Header
        296,//Reminder Line
        299,//Reminder Comment Line
        302,//Finance Charge Memo Header
        303,//Finance Charge Memo Line
        306,//Fin. Charge Comment Line
        426,//IC Outbox Sales Header
        427,//IC Outbox Sales Line
        428,//IC Outbox Purchase Header
        429,//IC Outbox Purchase Line
        434,//IC Inbox Sales Header
        435,//IC Inbox Sales Line
        436,//IC Inbox Purchase Header
        437,//IC Inbox Purchase Line
        900,//Assembly Header
        901,//Assembly Line
        906,//Assembly Comment Line
        950,//Time Sheet Header
        951,//Time Sheet Line
        953,//Time Sheet Comment Line
        1701,//Deferral Header
        1702,//Deferral Line
        5076,//Segment Header
        5077,//Segment Line
        5740,//Transfer Header
        5741,//Transfer Line
        5766,//Warehouse Activity Header
        5767,//Warehouse Activity Line
        5770,//Warehouse Comment Line
        5900,//Service Header
        5901,//Service Item Line
        5902,//Service Line
        5906,//Service Comment Line
        5943,//Troubleshooting Header
        5944,//Troubleshooting Line
        5964,//Service Contract Line
        5965,//Service Contract Header
        7307,//Put-away Template Header
        7308,//Put-away Template Line
        7316,//Warehouse Receipt Header
        7317,//Warehouse Receipt Line
        7320,//Warehouse Shipment Header
        7321,//Warehouse Shipment Line
        7331,//Whse. Internal Put-away Header
        7332,//Whse. Internal Put-away Line
        7333,//Whse. Internal Pick Header
        7334,//Whse. Internal Pick Line
        7346,//Internal Movement Header
        7347,//Internal Movement Line
        7700,//Miniform Header
        7701,//Miniform Line
        6014405,//Sale POS
        6014406,//Sale Line POS
        6014425,//Retail Document Header
        6014426,//Retail Document Lines
        6151057,//Distribution Headers
        6151058,//Distribution Lines
        99000763,//Routing Header
        99000764,//Routing Line
        99000771,//Production BOM Header
        99000772,//Production BOM Line
        99000775,//Routing Comment Line
        99000776//Production BOM Comment Line
        ]);
        //+NPR5.44 [322867]
    end;

    local procedure IsMustAvoidTable(TableNo: Integer): Boolean
    begin
        //-NPR5.44 [322867]
        exit(TableNo in [
        2162,//O365 C2Graph Event Settings
        2163,//O365 Sales Event
        2190,//O365 Sales Graph
        2200,//O365 Sales Invoice Document
        5300,//Outlook Synch. Entity
        5301,//Outlook Synch. Entity Element
        5302,//Outlook Synch. Link
        5303,//Outlook Synch. Filter
        5304,//Outlook Synch. Field
        5305,//Outlook Synch. User Setup
        5306,//Outlook Synch. Lookup Name
        5307,//Outlook Synch. Option Correl.
        5310,//Outlook Synch. Setup Detail
        5311,//Outlook Synch. Dependency
        5320,//Exchange Folder
        5324,//Exchange Service Setup
        5329,//CRM Redirect
        5330,//CRM Connection Setup
        5331,//CRM Integration Record
        5450,//Graph Contact
        5451,//Graph Integration Record
        5452,//Graph Integration Rec. Archive
        5455,//Graph Subscription
        5456,//Graph Business Profile
        6700,//Exchange Sync
        6701,//Exchange Contact
        6702,//Booking Sync
        6703,//Booking Service
        6704,//Booking Mailbox
        6705,//Booking Staff
        6706,//Booking Service Mapping
        6707,//Booking Item
        6710,//Tenant Web Service OData
        6711,//Tenant Web Service Columns
        6712,//Tenant Web Service Filter
        8613,//Config. Package Table
        8614,//Config. Package Record
        8615,//Config. Package Data
        8616,//Config. Package Field
        8617,//Config. Package Error
        8623,//Config. Package
        8630,//Config. Media Buffer
        6014621,//POS Web Font
        6014623,//.NET Assembly
        6014624,//Web Client Dependency
        6150703,//POS Action
        6150704,//POS Action Parameter
        6150713,//POS Stargate Package
        6150714,//POS Stargate Package Method
        2000000069//Add-in
        ]);
        //+NPR5.44 [322867]
    end;

    local procedure IsPepperTable(TableNo: Integer): Boolean
    begin
        //-NPR5.45 [322867]
        exit(TableNo in [
        6184490,//Pepper Configuration
        6184491,//Pepper Instance
        6184492,//Pepper Terminal
        6184493,//Pepper Terminal Type
        6184494//Pepper Version
        ]);
    end;

    local procedure IsTableObsolete(TableNo: Integer): Boolean
    var
        TableMetadata: Record "Table Metadata";
    begin
        //-NPR5.53 [385785]
        if TableMetadata.Get(TableNo) then
          exit(TableMetadata.ObsoleteState = TableMetadata.ObsoleteState::Removed);
        exit(false);
        //+NPR5.53 [385785]
    end;
}

