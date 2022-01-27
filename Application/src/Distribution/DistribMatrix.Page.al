page 6151061 "NPR Distrib. Matrix"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Matrix';
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR Item Hierarchy Line";
    SourceTableView = SORTING("Linked Table Key Value");
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control26)
            {
                IndentationColumn = Rec."Item Hierarchy Level";
                IndentationControls = "Item Hierachy Description";
                ShowAsTree = true;
                ShowCaption = false;
                field("Item Hierachy Description"; Rec."Item Hierachy Description")
                {

                    ToolTip = 'Specifies the value of the Item Hierachy Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Hierarchy Level"; Rec."Item Hierarchy Level")
                {

                    ToolTip = 'Specifies the value of the Item Hierarchy Level field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Desc."; Rec."Item Desc.")
                {

                    ToolTip = 'Specifies the value of the Item Desciption field';
                    ApplicationArea = NPRRetail;
                }
                field(Total; TotalToDistribuate)
                {

                    Caption = 'Total';
                    ToolTip = 'Specifies the value of the Total field';
                    ApplicationArea = NPRRetail;
                }
                field(Field1; MATRIX_CellData[1])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[1];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[1] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(1);
                    end;
                }
                field(Field2; MATRIX_CellData[2])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[2];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[2] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(2);
                    end;
                }
                field(Field3; MATRIX_CellData[3])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[3];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[3] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(3);
                    end;
                }
                field(Field4; MATRIX_CellData[4])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[4];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[4] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(4);
                    end;
                }
                field(Field5; MATRIX_CellData[5])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[5];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[5] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(5);
                    end;
                }
                field(Field6; MATRIX_CellData[6])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[6];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[6] field';
                    ApplicationArea = NPRRetail;

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

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[7];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[7] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(7);
                    end;
                }
                field(Field8; MATRIX_CellData[8])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[8];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[8] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(8);
                    end;
                }
                field(Field9; MATRIX_CellData[9])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[9];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[9] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(9);
                    end;
                }
                field(Field10; MATRIX_CellData[10])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[10];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[10] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(10);
                    end;
                }
                field(Field11; MATRIX_CellData[11])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[11];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[11] field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        MATRIX_OnDrillDown(11);
                    end;
                }
                field(Field12; MATRIX_CellData[12])
                {

                    AutoFormatType = 10;
                    CaptionClass = '3,' + MATRIX_CaptionSetShown[12];
                    Style = Strong;
                    Visible = true;
                    ToolTip = 'Specifies the value of the MATRIX_CellData[12] field';
                    ApplicationArea = NPRRetail;

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
        Item: Record Item;
        RetaiReplDemandLine: Record "NPR Retail Repl. Demand Line";
    begin
        i := 0;
        TotalToDistribuate := 0;
        DistributionGroupMembersGV.SetRange("Distribution Group", DistributionHeadersGV."Distribution Group");
        if DistributionGroupMembersGV.FindSet() then begin
            repeat
                //display Available for take
                Item.SetRange("No.", Rec."Item No.");
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
                DistributionLinesGV.SetRange("Distribution Item", Rec."Item No.");
                //fix int issue
                DistributionLinesGV.SetRange("Distribution Group Member", Format(DistributionGroupMembersGV."Distribution Member Id"));
                DistributionLinesGV.CalcSums("Distribution Quantity", "Org. Distribution Quantity");
                if DistributionLinesGV.FindSet() then begin
                    MATRIX_CellData[i] := Format(DistributionLinesGV."Avaliable Quantity") + '/' + Format(DistributionLinesGV."Demanded Quantity") + '/' + Format(DistributionLinesGV."Distribution Quantity");
                end else
                    MATRIX_CellData[i] := 'N/A';
                if Rec."Item No." = '' then
                    MATRIX_CellData[i] := '';
                //
                TotalToDistribuate += DistributionLinesGV."Distribution Quantity";
            until DistributionGroupMembersGV.Next() = 0;
        end;
    end;

    var
        MATRIX_CellData: array[500] of Text[30];
        MATRIX_CaptionSet: array[500] of Text[80];
        MATRIX_CaptionSetShown: array[12] of Text[80];
        i: Integer;
        MATRIX_CurrentColumnOrdinal: array[500] of Integer;
        DistributionGroupMembersGV: Record "NPR Distrib. Group Members";
        DistributionLinesGV: Record "NPR Distribution Lines";
        DistributionHeadersGV: Record "NPR Distribution Headers";
        TotalToDistribuate: Decimal;
        LastColumnShown: Integer;
        NewLastColumnShown: Integer;

    local procedure MATRIX_OnDrillDown(INT: Integer)
    var
        DistributionLines: Record "NPR Distribution Lines";
        DistributionLinesPage: Page "NPR Distribution Lines";
    begin
        DistributionLines.SetRange("Distribution Id", DistributionHeadersGV."Distribution Id");
        DistributionLines.SetRange("Distribution Item", Rec."Item No.");

        //Fix int issue
        DistributionLines.SetRange("Distribution Group Member", Format(MATRIX_CurrentColumnOrdinal[INT]));
        if DistributionLines.FindSet() then begin
            DistributionLinesPage.SetTableView(DistributionLines);
            DistributionLinesPage.RunModal();
        end;

        // IF "Item No." <> '' THEN
        //  FOR i := 1 TO DistributionGroupMembers.Count() DO
        //    MATRIX_CellData[i] := FORMAT(DistributionLines."Distribution Quantity") +'/'+ FORMAT(DistributionLines."Avaliable Quantity");
        // CurrPage.Update();
    end;

    procedure Load(var DistributionHeaders: Record "NPR Distribution Headers")
    var
        DistributionGroupMembers: Record "NPR Distrib. Group Members";
    begin
        NewLastColumnShown := GetLastColumnShown();
        LastColumnShown := NewLastColumnShown;
        i := 0;
        //IF DistributionHeaders.GET(DistributionID) THEN;
        DistributionGroupMembers.SetRange(DistributionGroupMembers."Distribution Group", DistributionHeaders."Distribution Group");
        if DistributionGroupMembers.FindSet() then begin
            repeat
                i := i + 1;
                //MATRIX_CaptionSet[i] := FORMAT(DistributionGroupMembers."Distribution Member Id");
                MATRIX_CaptionSet[i] := 'Store:' + Format(DistributionGroupMembers.Store) + ' Loc.:' + Format(DistributionGroupMembers.Location) + ' ' + 'Avail.\Demand\Dist.';
                MATRIX_CurrentColumnOrdinal[i] := DistributionGroupMembers."Distribution Member Id";
            until DistributionGroupMembers.Next() = 0;
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

