page 6014558 "NPR MM Membership Entries View"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM Membership Entry";
    SourceTableTemporary = true;
    Editable = false;
    Caption = 'Membership Entries';
    DataCaptionExpression = _LookupCaption;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Context; Rec.Context)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Context field';
                }
                field("Original Context"; Rec."Original Context")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Original Context field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid From Date field';
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until Date field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
            }
        }
    }

    var
        _LookupCaption: Text;

    procedure LoadEntries(LookupCaption: Text; var TmpMembershipEntry: Record "NPR MM Membership Entry" temporary)
    begin
        _LookupCaption := LookupCaption;
        Rec.Copy(TmpMembershipEntry, true);
    end;

}