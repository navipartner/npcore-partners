page 6014426 "NPR MM Membership Entries View"
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
                }
                field("Original Context"; Rec."Original Context")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = All;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
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