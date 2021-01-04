page 6059972 "NPR Variety Table"
{
    // VRT1.10/JDH/20160105 CASE 201022 Added field "Lock Table"
    // VRT1.11/JDH /20160602 CASE 242940 Added setup new line
    // NPR5.41/TS  /20180105 CASE 300893 ActionContainers cannot have captions

    Caption = 'Variety Table';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Variety Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Use in Variant Description"; "Use in Variant Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use in Variant Description field';
                }
                field("Pre tag In Variant Description"; "Pre tag In Variant Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pre tag In Variant Description field';
                }
                field("Use Description field"; "Use Description field")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Description field field';
                }
                field("Lock Table"; "Lock Table")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lock Table field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Values)
            {
                Caption = 'Values';
                Image = "Table";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Variety Value";
                RunPageLink = Type = FIELD(Type),
                              Table = FIELD(Code);
                RunPageView = SORTING(Type, Table, Value);
                ApplicationArea = All;
                ToolTip = 'Executes the Values action';
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-VRT1.11
        SetupNewLine;
        //+VRT1.11
    end;
}

