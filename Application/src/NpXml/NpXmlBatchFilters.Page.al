page 6151557 "NPR NpXml Batch Filters"
{
    AutoSplitKey = true;
    Caption = 'Xml Batch Filters';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR NpXml Filter";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Filter Type"; Rec."Filter Type")
                {

                    OptionCaption = ',Constant,Filter';
                    ToolTip = 'Specifies the value of the Filter Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Parent Field No."; Rec."Parent Field No.")
                {

                    ToolTip = 'Specifies the value of the Parent Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Parent Field Name"; Rec."Parent Field Name")
                {

                    ToolTip = 'Specifies the value of the Parent Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Value"; Rec."Filter Value")
                {

                    ToolTip = 'Specifies the value of the Filter Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Parent Table No." := ParentTableNo;
        Rec."Filter Type" := Rec."Filter Type"::Constant;
    end;

    var
        ParentTableNo: Integer;

    procedure SetParentTableNo(NewParentTableNo: Integer)
    begin
        ParentTableNo := NewParentTableNo;
    end;
}

