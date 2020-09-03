page 6151061 "NPR Distrib. Matrix"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Matrix';
    PageType = ListPart;
    SourceTable = "NPR Item Hierarchy Line";
    SourceTableView = SORTING("Linked Table Key Value");

    layout
    {
        area(content)
        {
            repeater(Control26)
            {
                IndentationColumn = "Item Hierarchy Level";
                IndentationControls = "Item Hierachy Description";
                ShowAsTree = true;
                ShowCaption = false;
                field("Item Hierachy Description"; "Item Hierachy Description")
                {
                    ApplicationArea = All;
                }
                field("Item Hierarchy Level"; "Item Hierarchy Level")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item Desc."; "Item Desc.")
                {
                    ApplicationArea = All;
                }
                field(Total; TotalToDistribuate)
                {
                    ApplicationArea = All;
                    Caption = 'Total';
                }
                field(Field1; MATRIX_CellData[1])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[1];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[2];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[3];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[4];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[5];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[6];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(6);
                    end;

                    trigger OnValidate()
                    begin
                        // UpdateAmount(1);
                    end;
                }
                field(Field7; MATRIX_CellData[7])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[7];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[8];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[9];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[10];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[11];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {
                    ApplicationArea = All;
                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[12];
                    Style = Strong;
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(12);
                    end;

                    trigger OnValidate()
                    begin
                        // UpdateAmount(1);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        MatrixDistributionLines: array[12] of Record "NPR Distribution Lines";
        Item: Record Item;
        RetaiReplDemandLine: Record "NPR Retail Repl. Demand Line";
    begin
        i := 0;
        TotalToDistribuate := 0;
        DistributionGroupMembersGV.SetRange("Distribution Group", DistributionHeadersGV."Distribution Group");
        if DistributionGroupMembersGV.FindSet then begin
            repeat
                //display Available for take
                Item.SetRange("No.", "Item No.");
                Item.SetFilter("Date Filter", '..%1', DistributionHeadersGV."Required Date");
                //location FILTER ??
                Item.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. on Sales Order");

                DistributionLinesGV."Avaliable Quantity" := Item.Inventory + Item."Qty. on Purch. Order" - Item."Qty. on Sales Order";
                //inventory + purch - sales
                //display Demands
                RetaiReplDemandLine.SetRange(RetaiReplDemandLine."Item No.", Item."No.");
                RetaiReplDemandLine.SetRange(Confirmed, true);
                RetaiReplDemandLine.SetRange("Location Code", DistributionGroupMembersGV.Location);
                RetaiReplDemandLine.SetFilter("Due Date", '..%1', DistributionHeadersGV."Required Date");
                RetaiReplDemandLine.CalcSums("Demand Quantity");

                //display Distributions
                i := i + 1;
                DistributionLinesGV.SetRange("Distribution Id", DistributionHeadersGV."Distribution Id");
                DistributionLinesGV.SetRange("Distribution Item", "Item No.");
                //fix int issue
                DistributionLinesGV.SetRange("Distribution Group Member", Format(DistributionGroupMembersGV."Distribution Member Id"));
                DistributionLinesGV.CalcSums("Distribution Quantity", "Org. Distribution Quantity");
                if DistributionLinesGV.FindSet then begin
                    MATRIX_CellData[i] := Format(DistributionLinesGV."Avaliable Quantity") + '/' + Format(DistributionLinesGV."Demanded Quantity") + '/' + Format(DistributionLinesGV."Distribution Quantity");
                end else
                    MATRIX_CellData[i] := 'N/A';
                if "Item No." = '' then
                    MATRIX_CellData[i] := '';
                //
                TotalToDistribuate += DistributionLinesGV."Distribution Quantity";
            until DistributionGroupMembersGV.Next = 0;
        end;
    end;

    var
        MatrixMgt: Codeunit "Matrix Management";
        MATRIX_CurrentNoOfMatrixColumn: Integer;
        MATRIX_CellData: array[500] of Text[30];
        MATRIX_CaptionSet: array[500] of Text[80];
        MATRIX_CaptionSetShown: array[12] of Text[80];
        MatrixHeader: Text[50];
        Emphasize: Text;
        FieldVisible: array[500] of Boolean;
        ShowColumnName: Boolean;
        i: Integer;
        MATRIX_CurrentColumnOrdinal: array[500] of Integer;
        DistributionGroupMembersGV: Record "NPR Distrib. Group Members";
        DistributionLinesGV: Record "NPR Distribution Lines";
        DistributionHeadersGV: Record "NPR Distribution Headers";
        DistributionID: Integer;
        ColumnTextHeaderDistAvail: Label 'Distribute / Avaliable';
        TotalToDistribuate: Decimal;
        LastColumnShown: Integer;
        NewLastColumnShown: Integer;

    local procedure FormatStr()
    begin
    end;

    local procedure UpdateAmount(INT: Integer)
    begin
    end;

    local procedure MATRIX_OnDrillDown(INT: Integer)
    var
        DistributionLines: Record "NPR Distribution Lines";
        DistributionLinesPage: Page "NPR Distribution Lines";
    begin
        DistributionLines.SetRange("Distribution Id", DistributionHeadersGV."Distribution Id");
        DistributionLines.SetRange("Distribution Item", "Item No.");

        //Fix int issue
        DistributionLines.SetRange("Distribution Group Member", Format(MATRIX_CurrentColumnOrdinal[INT]));
        if DistributionLines.FindSet then begin
            DistributionLinesPage.SetTableView(DistributionLines);
            DistributionLinesPage.RunModal();
        end;

        // IF "Item No." <> '' THEN
        //  FOR i := 1 TO DistributionGroupMembers.COUNT DO
        //    MATRIX_CellData[i] := FORMAT(DistributionLines."Distribution Quantity") +'/'+ FORMAT(DistributionLines."Avaliable Quantity");
        // CurrPage.UPDATE;
    end;

    local procedure MATRIX_OnAfterGetRecord(MATRIX_ColumnOrdinal: Integer)
    var
        DistributionLines: Record "NPR Distribution Lines";
    begin


        DistributionLines.SetRange(DistributionLines."Distribution Id", DistributionID);
        DistributionLines.SetRange("Distribution Item", "Item No.");
        //fix int issue
        DistributionLines.SetRange(DistributionLines."Distribution Group Member", Format(DistributionGroupMembersGV."Distribution Member Id"));
        if DistributionLines.FindSet then begin
            repeat
                MATRIX_CellData[MATRIX_ColumnOrdinal] := Format(DistributionLines."Distribution Quantity" + MATRIX_ColumnOrdinal);
            until DistributionLines.Next = 0;
        end;




        //IF ShowColumnName THEN
        //MatrixHeader := FORMAT(MatrixDistributionLines[MATRIX_ColumnOrdinal]."Distribution Group Member");
        //ELSE
        //  MatrixHeader := MatrixRecords[MATRIX_ColumnOrdinal].Code;
        //MATRIX_MatrixRecord := MatrixRecords[MATRIX_ColumnOrdinal];
        //MATRIX_CellData[MATRIX_ColumnOrdinal] := 'TEST' + FORMAT(MATRIX_ColumnOrdinal);
    end;

    procedure SetMatrixFilter(DistID: Integer)
    begin
        DistributionID := DistID;
    end;

    procedure Load(var DistributionHeaders: Record "NPR Distribution Headers")
    var
        DistributionGroups: Record "NPR Distrib. Group";
        DistributionGroupMembers: Record "NPR Distrib. Group Members";
        DistributionLines: Record "NPR Distribution Lines";
    begin
        NewLastColumnShown := GetLastColumnShown;
        LastColumnShown := NewLastColumnShown;
        i := 0;
        //IF DistributionHeaders.GET(DistributionID) THEN;
        DistributionGroupMembers.SetRange(DistributionGroupMembers."Distribution Group", DistributionHeaders."Distribution Group");
        if DistributionGroupMembers.FindSet then begin
            repeat
                i := i + 1;
                //MATRIX_CaptionSet[i] := FORMAT(DistributionGroupMembers."Distribution Member Id");
                MATRIX_CaptionSet[i] := 'Store:' + Format(DistributionGroupMembers.Store) + ' Loc.:' + Format(DistributionGroupMembers.Location) + ' ' + 'Avail.\Demand\Dist.';
                MATRIX_CurrentColumnOrdinal[i] := DistributionGroupMembers."Distribution Member Id";
            until DistributionGroupMembers.Next = 0;
        end;

        for i := 1 to 12 do begin
            MATRIX_CaptionSetShown[i] := MATRIX_CaptionSet[LastColumnShown + i];
            //IF MATRIX_CaptionSet[LastColumnShown + i] <> '' THEN
            //  SetLastColumnShown(LastColumnShown + i);
        end;


        DistributionHeadersGV := DistributionHeaders;
        // MESSAGE(FORMAT(NewLastColumnShown));
    end;

    procedure SetLastColumnShown(ColumnNo: Integer)
    begin
        LastColumnShown := ColumnNo;
    end;

    procedure GetLastColumnShown(): Integer
    begin
        exit(LastColumnShown);
    end;
}

