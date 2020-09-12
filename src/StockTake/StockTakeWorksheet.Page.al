page 6014663 "NPR Stock-Take Worksheet"
{
    // NPR4.16/TS/20150525  CASE 213313 Page Created
    // NPR4.16/TSA/20150924 CASE 223529 Added support for importing worksheets and lines
    // NPR5.39/TJ  /20180208  CASE 302634 Removed unused variables and renamed functions to english
    // NPR5.40/TSA /20180316 CASE 308391 Housecleaning for V2, removed 4 unused functions
    // NPR5.48/TSA /20181022 CASE 332846 Added AreaTopUp function
    // NPR5.48/CLVA/20181024 CASE 332846 Added field "Topup Worksheet"
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.49/TSA /20190318 CASE 348372 Added line counts statistics

    Caption = 'Stock-Take Worksheet';
    DelayedInsert = true;
    InsertAllowed = false;
    SourceTable = "NPR Stock-Take Worksheet";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control6150614)
            {
                ShowCaption = false;
                field(ConfigurationCode; ConfigurationCode)
                {
                    ApplicationArea = All;
                    Caption = 'Stock-Take Code';

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        CurrPage.SaveRecord;
                        StockTakeMgr.LookupConfigurationCode(ConfigurationCode, Rec);
                        WorksheetName := '';
                        StockTakeMgr.SetWorksheetName(WorksheetName, Rec);

                        CurrPage.Update(false);
                    end;

                    trigger OnValidate()
                    begin

                        StockTakeMgr.CheckConfigurationCode(ConfigurationCode, Rec);
                        WorksheetName := '';
                        StockTakeMgr.SetWorksheetName(WorksheetName, Rec);

                        ConfigurationCodeOnAfterValidate();
                    end;
                }
                field("Conf Item Group Filter"; "Conf Item Group Filter")
                {
                    ApplicationArea = All;
                }
                field("Conf Vendor Code Filter"; "Conf Vendor Code Filter")
                {
                    ApplicationArea = All;
                }
                field("Conf Calc. Date"; "Conf Calc. Date")
                {
                    ApplicationArea = All;
                }
                field("Conf Location Code"; "Conf Location Code")
                {
                    ApplicationArea = All;
                }
                field("Conf Stock Take Method"; "Conf Stock Take Method")
                {
                    ApplicationArea = All;
                }
                field("Conf Adjustment Method"; "Conf Adjustment Method")
                {
                    ApplicationArea = All;
                }
            }
            group(Control6150649)
            {
                ShowCaption = false;
                field(WorksheetName; WorksheetName)
                {
                    ApplicationArea = All;
                    Caption = 'Worksheet Name';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CurrPage.SaveRecord;
                        "Stock-Take Config Code" := ConfigurationCode;
                        StockTakeMgr.LookupWorksheetName(WorksheetName, Rec);
                        CurrPage.Update(false);
                        CurrPage.SubPage.PAGE.Update(false);
                    end;

                    trigger OnValidate()
                    begin
                        StockTakeMgr.SetConfigurationCode(ConfigurationCode, Rec);
                        StockTakeMgr.CheckWorksheetName(WorksheetName, Rec);

                        WorkSheetNameOnAfterValidate()
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Item Group Filter"; "Item Group Filter")
                {
                    ApplicationArea = All;
                }
                field("Vendor Code Filter"; "Vendor Code Filter")
                {
                    ApplicationArea = All;
                }
                field("Topup Worksheet"; "Topup Worksheet")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
            }
            part(SubPage; "NPR StockTake Worksh. Line")
            {
                SubPageLink = "Stock-Take Config Code" = FIELD("Stock-Take Config Code"),
                              "Worksheet Name" = FIELD(Name);
                ApplicationArea = All;
            }
            field(LineTypeCountText; LineTypeCountText)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
                Style = Favorable;
                StyleExpr = TRUE;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("Import from &File")
                {
                    Caption = 'Import from &File';
                    Image = Import;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        StockTakeWorkSheetName: Record "NPR Stock-Take Worksheet";
                        StockTakeWorkSheetLine: Record "NPR Stock-Take Worksheet Line";
                    begin
                        //-NPR4.16
                        //ERROR('Need to Convert Dataport');

                        StockTakeMgr.ImportPreHandler(Rec);
                        StockTakeWorkSheetName := Rec;
                        StockTakeWorkSheetName.SetRecFilter;
                        StockTakeWorkSheetLine.SetRange("Stock-Take Config Code", StockTakeWorkSheetName."Stock-Take Config Code");
                        StockTakeWorkSheetLine.SetRange("Worksheet Name", StockTakeWorkSheetName.Name);
                        if (StockTakeWorkSheetLine.IsEmpty()) then;
                        //DATAPORT.RUNMODAL(DATAPORT::"Indlæsning af Status tal fra", TRUE, StockTakeWorkSheetLine);
                        XMLPORT.Run(XMLPORT::"NPR Import StockT.Wrksht.Line", false, true, StockTakeWorkSheetLine);
                        StockTakeMgr.ImportPostHandler(Rec);

                        //+NPR4.16
                    end;
                }
                action("Import from Scanner")
                {
                    Caption = '&Import from Scanner';
                    Image = Import;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        StockTakeMgr.ImportPreHandler(Rec);
                        ScannerFunctions.initStockTake(Rec);
                        StockTakeMgr.ImportPostHandler(Rec);
                    end;
                }
                action("Import Worksheets & Lines")
                {
                    Caption = 'Import Worksheets & Lines';
                    Image = Import;
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        StockTakeWorkSheet: Record "NPR Stock-Take Worksheet";
                        StockTakeWorkSheetLine: Record "NPR Stock-Take Worksheet Line";
                        StockTakeConfigCode: Code[20];
                    begin
                        //-NPR4.16
                        StockTakeMgr.ImportPreHandler(Rec);
                        StockTakeWorkSheet := Rec;
                        StockTakeWorkSheet.SetRecFilter;
                        StockTakeWorkSheetLine.SetRange("Stock-Take Config Code", StockTakeWorkSheet."Stock-Take Config Code");
                        StockTakeWorkSheetLine.SetRange("Worksheet Name", StockTakeWorkSheet.Name);
                        if (StockTakeWorkSheetLine.IsEmpty()) then;
                        XMLPORT.Run(XMLPORT::"NPR Import M.StockTake Wrksht.", false, true, StockTakeWorkSheetLine);

                        StockTakeConfigCode := "Stock-Take Config Code";
                        StockTakeWorkSheet.Reset();
                        StockTakeWorkSheet.SetFilter("Stock-Take Config Code", '=%1', StockTakeConfigCode);
                        if (StockTakeWorkSheet.FindSet()) then begin
                            repeat
                                StockTakeMgr.ImportPostHandler(StockTakeWorkSheet);
                            until (StockTakeWorkSheet.Next() = 0);
                        end;

                        //+NPR4.16
                    end;
                }
                action("&Aggregate")
                {
                    Caption = '&Aggregate';
                    Image = Compress;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        StockTakeMgr.ImportPostHandler(Rec);
                    end;
                }
            }
            group("Stock -Take")
            {
                Caption = 'Stock -Take';
                action("Calc. Inventory and Transfer")
                {
                    Caption = 'Calc. Inventory and Transfer';
                    Image = Calculate;
                    ShortCutKey = 'F11';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        StockTakeWorkSheet: Record "NPR Stock-Take Worksheet";
                        Frm: Page "NPR StockTake Calc.Inv.Transf.";
                    begin
                        StockTakeWorkSheet.Get("Stock-Take Config Code", Name);
                        StockTakeWorkSheet.FilterGroup(2);
                        StockTakeWorkSheet.SetFilter("Stock-Take Config Code", '=%1', Rec."Stock-Take Config Code");
                        StockTakeWorkSheet.SetFilter(Name, '=%1', Rec.Name);
                        StockTakeWorkSheet.FilterGroup(0);
                        Frm.SetRecord(StockTakeWorkSheet);
                        Frm.SetTableView(StockTakeWorkSheet);
                        Frm.LookupMode(true);
                        if (Frm.RunModal = ACTION::LookupOK) then
                            StockTakeMgr.TransferToItemInvJnl(Rec, Frm.GetUserTransferAction(), Frm.GetPostingDate());
                    end;
                }
                action("Top-Up Area")
                {
                    Caption = 'Top-Up Area';
                    Image = CalculatePlan;
                    ApplicationArea = All;

                    trigger OnAction()
                    begin

                        //-NPR5.48 [332846]
                        StockTakeMgr.AreaTopUp(Rec);
                        //+NPR5.48 [332846]
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Configuration Card")
            {
                Caption = 'Configuration Card';
                Image = Setup;
                RunObject = Page "NPR Stock-Take Config. Card";
                RunPageLink = Code = FIELD("Stock-Take Config Code");
                ApplicationArea = All;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ConfigurationCode := "Stock-Take Config Code";
        WorksheetName := Name;
    end;

    trigger OnAfterGetRecord()
    begin
        ConfigurationCode := "Stock-Take Config Code";
        WorksheetName := Name;

        //-NPR5.49 [348372]
        CountWorksheetLines();
        //+NPR5.49 [348372]
    end;

    trigger OnInit()
    begin
        Reset;
    end;

    var
        StockTakeMgr: Codeunit "NPR Stock-Take Manager";
        ConfigurationCode: Code[20];
        WorksheetName: Code[20];
        ScannerFunctions: Codeunit "NPR Scanner - Functions";
        Text000: Label 'This function deletes all lines in all statusjournals.\Continue?';
        Text001: Label 'Are You sure?';
        Text002: Label 'Inventory worksheet %1 %2 (%3) is not empty.';
        Text003: Label 'Inventory worksheet is transfered to Item Journal.';
        LineTypeCountText: Text;

    procedure ConfigurationCodeOnAfterValidate()
    begin
        CurrPage.SaveRecord;
        StockTakeMgr.LookupConfigurationCode(ConfigurationCode, Rec);
        WorksheetName := '';
        StockTakeMgr.SetWorksheetName(WorksheetName, Rec);

        CurrPage.Update(false);

        //-NPR5.49 [348372]
        CountWorksheetLines();
        //+NPR5.49 [348372]
    end;

    procedure WorkSheetNameOnAfterValidate()
    begin
        StockTakeMgr.SetWorksheetName(WorksheetName, Rec);
        CurrPage.Update(false);

        //-NPR5.49 [348372]
        CountWorksheetLines();
        //+NPR5.49 [348372]
    end;

    local procedure CountWorksheetLines()
    var
        StockTakeWorksheet: Record "NPR Stock-Take Worksheet";
        StockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
        WorksheetsCount: Integer;
        WorksheetLinesCount: Integer;
        ReadyCount: Integer;
        IgnoreCount: Integer;
        TransferCount: Integer;
    begin

        //-NPR5.49 [348372]
        StockTakeWorksheet.SetFilter("Stock-Take Config Code", '=%1', ConfigurationCode);
        WorksheetsCount := StockTakeWorksheet.Count();

        StockTakeWorksheetLine.SetFilter("Stock-Take Config Code", '=%1', ConfigurationCode);
        StockTakeWorksheetLine.SetFilter("Worksheet Name", '=%1', WorksheetName);
        WorksheetLinesCount := StockTakeWorksheetLine.Count();

        StockTakeWorksheetLine.SetFilter("Transfer State", '=%1', StockTakeWorksheetLine."Transfer State"::READY);
        ReadyCount := StockTakeWorksheetLine.Count();

        StockTakeWorksheetLine.SetFilter("Transfer State", '=%1', StockTakeWorksheetLine."Transfer State"::IGNORE);
        IgnoreCount := StockTakeWorksheetLine.Count();

        StockTakeWorksheetLine.SetFilter("Transfer State", '=%1', StockTakeWorksheetLine."Transfer State"::TRANSFERRED);
        TransferCount := StockTakeWorksheetLine.Count();

        LineTypeCountText := StrSubstNo('%1: %2, %3: %4 [%5/%6/%7]', ConfigurationCode, WorksheetsCount, WorksheetName, WorksheetLinesCount, ReadyCount, IgnoreCount, TransferCount);
        //+NPR5.49 [348372]
    end;
}

