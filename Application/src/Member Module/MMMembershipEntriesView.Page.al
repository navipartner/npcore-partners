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

                    ToolTip = 'Specifies the value of the Context field';
                    ApplicationArea = NPRRetail;
                }
                field("Original Context"; Rec."Original Context")
                {

                    ToolTip = 'Specifies the value of the Original Context field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {

                    ToolTip = 'Specifies the value of the Valid From Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {

                    ToolTip = 'Specifies the value of the Valid Until Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {

                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
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