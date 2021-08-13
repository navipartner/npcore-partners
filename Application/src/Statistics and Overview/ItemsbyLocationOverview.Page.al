page 6060066 "NPR Items by Location Overview"
{
    // NPR5.52/JAKUBV/20191022  CASE 370333 Transport NPR5.52 - 22 October 2019

    Caption = 'Items by Location Overview';
    PageType = ListPlus;
    UsageCategory = Administration;

    SaveValues = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ShowItems; ShowItems)
                {

                    Caption = 'Show Items';
                    OptionCaption = 'On Inventory,Not on Inventory,All';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Show Items field';
                    ApplicationArea = NPRRetail;
                }
                field(ShowInTransit; ShowInTransit)
                {

                    Caption = 'Show Items in Transit';
                    ToolTip = 'Specifies the value of the Show Items in Transit field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RefreshMatrix(MATRIX_SetWanted::Initial);
                    end;
                }
                field(ShowColumnName; ShowColumnName)
                {

                    Caption = 'Show Column Name';
                    ToolTip = 'Specifies the value of the Show Column Name field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RefreshMatrix(MATRIX_SetWanted::Same);
                    end;
                }
            }
            part(MATRIX; "NPR Items by Loc.Overv. Matrix")
            {
                ApplicationArea = NPRRetail;

            }
            group(Filters)
            {
                Caption = 'Filters';
                field(ItemFilter; ItemFilter)
                {

                    Caption = 'Item Filter';
                    ToolTip = 'Specifies the value of the Item Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                        ItemList: Page "Item List";
                    begin
                        Item.SetRange(Blocked, false);
                        if ItemFilter <> '' then begin
                            Item.SetFilter("No.", ItemFilter);
                            if Item.FindFirst() then;
                            Item.SetRange("No.");
                        end;
                        ItemList.SetTableView(Item);
                        ItemList.SetRecord(Item);
                        ItemList.LookupMode(true);
                        if ItemList.RunModal() = ACTION::LookupOK then begin
                            Text := ItemList.GetSelectionFilter();
                            exit(true);
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        FilterOnAfterValidate();
                    end;
                }
                field(VariantFilter; VariantFilter)
                {

                    Caption = 'Variant Filter';
                    ToolTip = 'Specifies the value of the Variant Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        FilterOnAfterValidate();
                    end;
                }
                field("VarietyValueFilter[1]"; VarietyValueFilter[1])
                {

                    Caption = 'Variety 1 Value Filter';
                    ToolTip = 'Specifies the value of the Variety 1 Value Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        FilterOnAfterValidate();
                    end;
                }
                field("VarietyValueFilter[2]"; VarietyValueFilter[2])
                {

                    Caption = 'Variety 2 Value Filter';
                    ToolTip = 'Specifies the value of the Variety 2 Value Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        FilterOnAfterValidate();
                    end;
                }
                field("VarietyValueFilter[3]"; VarietyValueFilter[3])
                {

                    Caption = 'Variety 3 Value Filter';
                    ToolTip = 'Specifies the value of the Variety 3 Value Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        FilterOnAfterValidate();
                    end;
                }
                field("VarietyValueFilter[4]"; VarietyValueFilter[4])
                {

                    Caption = 'Variety 4 Value Filter';
                    ToolTip = 'Specifies the value of the Variety 4 Value Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        FilterOnAfterValidate();
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Previous Set")
            {
                Caption = 'Previous Set';
                Image = PreviousSet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous Set';
                ApplicationArea = NPRRetail;


                trigger OnAction()
                begin
                    RefreshMatrix(MATRIX_SetWanted::Previous);
                end;
            }
            action("Previous Column")
            {
                Caption = 'Previous Column';
                Image = PreviousRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous Set';
                ApplicationArea = NPRRetail;


                trigger OnAction()
                begin
                    RefreshMatrix(MATRIX_SetWanted::PreviousColumn);
                end;
            }
            action("Next Column")
            {
                Caption = 'Next Column';
                Image = NextRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next Set';
                ApplicationArea = NPRRetail;


                trigger OnAction()
                begin
                    RefreshMatrix(MATRIX_SetWanted::NextColumn);
                end;
            }
            action("Next Set")
            {
                Caption = 'Next Set';
                Image = NextSet;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next Set';
                ApplicationArea = NPRRetail;


                trigger OnAction()
                begin
                    RefreshMatrix(MATRIX_SetWanted::Next);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ShowItems := ShowItems::All;
        SetColumns(MATRIX_SetWanted::Initial);
        UpdateMatrixSubPage();
    end;

    var
        TempMatrixRecord: Record Location temporary;
        MatrixRecords: array[32] of Record Location;
        MatrixSubPage: Page "NPR Items by Loc.Overv. Matrix";
        MATRIX_SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
        ShowItems: Option "On Inventory","Not on Inventory",All;
        MATRIX_CurrSetLength: Integer;
        ItemFilter: Code[250];
        LocationFilter: Code[250];
        VariantFilter: Code[250];
        VarietyValueFilter: array[4] of Code[250];
        MATRIX_CaptionRange: Text;
        MATRIX_CaptionSet: array[32] of Text[80];
        MATRIX_PKFirstRecInCurrSet: Text;
        ShowColumnName: Boolean;
        ShowInTransit: Boolean;

    local procedure SetColumns(SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn)
    var
        MatrixRecord: Record Location;
        RecRef: RecordRef;
        MatrixMgt: Codeunit "Matrix Management";
        CaptionFieldNo: Integer;
        CurrentMatrixRecordOrdinal: Integer;
    begin
        if SetWanted = SetWanted::Initial then begin
            TempMatrixRecord.DeleteAll();
            MatrixRecord.Reset();
            if LocationFilter <> '' then
                MatrixRecord.SetFilter(Code, LocationFilter);
            MatrixRecord.SetRange("Use As In-Transit", ShowInTransit);
            if MatrixRecord.FindSet() then
                repeat
                    TempMatrixRecord := MatrixRecord;
                    TempMatrixRecord.Insert();
                until MatrixRecord.Next() = 0;
            if (LocationFilter = '') and not ShowInTransit then begin
                TempMatrixRecord.Init();
                TempMatrixRecord.Code := MatrixSubPage.EmptyCodeValue();
                TempMatrixRecord.Name := MatrixSubPage.EmptyCodeValue();
                TempMatrixRecord.Insert();
            end;
        end;

        Clear(MATRIX_CaptionSet);
        Clear(MatrixRecords);
        CurrentMatrixRecordOrdinal := 1;

        RecRef.GetTable(TempMatrixRecord);
        RecRef.SetTable(TempMatrixRecord);

        if ShowColumnName then
            CaptionFieldNo := MatrixRecord.FieldNo(Name)
        else
            CaptionFieldNo := MatrixRecord.FieldNo(Code);

        MatrixMgt.GenerateMatrixData(
          RecRef, SetWanted, MatrixSubPage.MatrixMaxNoOfColumns(), CaptionFieldNo, MATRIX_PKFirstRecInCurrSet,
          MATRIX_CaptionSet, MATRIX_CaptionRange, MATRIX_CurrSetLength);

        if MATRIX_CurrSetLength > 0 then begin
            TempMatrixRecord.SetPosition(MATRIX_PKFirstRecInCurrSet);
            TempMatrixRecord.Find();
            repeat
                MatrixRecords[CurrentMatrixRecordOrdinal].Copy(TempMatrixRecord);
                CurrentMatrixRecordOrdinal := CurrentMatrixRecordOrdinal + 1;
            until (CurrentMatrixRecordOrdinal > MATRIX_CurrSetLength) or (TempMatrixRecord.Next() <> 1);
        end;
    end;

    local procedure UpdateMatrixSubPage()
    begin
        CurrPage.MATRIX.PAGE.SetFilters(ItemFilter, VariantFilter, VarietyValueFilter, ShowItems);
        CurrPage.MATRIX.PAGE.Load(MATRIX_CaptionSet, MatrixRecords, TempMatrixRecord);
        CurrPage.Update(false);
    end;

    local procedure RefreshMatrix(Wanted: Option)
    begin
        SetColumns(Wanted);
        UpdateMatrixSubPage();
    end;

    local procedure FilterOnAfterValidate()
    begin
        RefreshMatrix(MATRIX_SetWanted::Same);
    end;

    procedure SetFilters(_LocationFilter: Code[250])
    begin
        LocationFilter := _LocationFilter;
    end;
}

