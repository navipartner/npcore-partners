page 6059972 "NPR Variety Table"
{
    // VRT1.10/JDH/20160105 CASE 201022 Added field "Lock Table"
    // VRT1.11/JDH /20160602 CASE 242940 Added setup new line
    // NPR5.41/TS  /20180105 CASE 300893 ActionContainers cannot have captions

    Caption = 'Variety Table';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Variety Table";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Use in Variant Description"; Rec."Use in Variant Description")
                {

                    ToolTip = 'Specifies the value of the Use in Variant Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Pre tag In Variant Description"; Rec."Pre tag In Variant Description")
                {

                    ToolTip = 'Specifies the value of the Pre tag In Variant Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Description field"; Rec."Use Description field")
                {

                    ToolTip = 'Specifies the value of the Use Description field field';
                    ApplicationArea = NPRRetail;
                }
                field("Lock Table"; Rec."Lock Table")
                {

                    ToolTip = 'Specifies the value of the Lock Table field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Variety Value";
                RunPageLink = Type = FIELD(Type),
                              Table = FIELD(Code);
                RunPageView = SORTING(Type, Table, Value);

                ToolTip = 'Executes the Values action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-VRT1.11
        Rec.SetupNewLine();
        //+VRT1.11
    end;
}

