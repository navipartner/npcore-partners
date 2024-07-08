#IF NOT BC17
page 6150624 "NPR POS Dimension Value"
{
    Caption = 'Dimension Value List';
    Editable = true;
    SourceTable = "Dimension Value";
    PageType = List;
    UsageCategory = Lists;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Auto setting focus on fields is not supported. If requested, please inform the customer how BC works and where the MS idea portal is if they wish the behaviour was different. See case 580270.';

    layout
    {
        area(content)
        {
            field(SearchBox; _SearchBox)
            {
                Editable = true;
                ApplicationArea = NPRRetail;
                Caption = 'Search Box';
                ToolTip = 'This is a search box for general search.';
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code for the dimension value.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a descriptive name for the dimension value.';
                }
            }
            usercontrol(SetFieldFocus; "NPR Dimensions SearchFocus")
            {
                ApplicationArea = NPRRetail;
            }
        }
    }
    var
        _SearchBox: Text;

    [Obsolete('The page has been removed. See case 580270.', 'NPR23.0')]
    procedure GetSelectionFilter(): Text
    begin
    end;

    [Obsolete('The page has been removed. See case 580270.', 'NPR23.0')]
    procedure SetSelection(var DimVal: Record "Dimension Value")
    begin
    end;
}
#ENDIF
