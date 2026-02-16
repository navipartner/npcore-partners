page 6150914 "NPR MM Loyalty Jnl Line Tags"
{
    Caption = 'Loyalty Journal Line Tags';
    PageType = List;
    SourceTable = "NPR MM Loyalty Jnl Line Tag";
    UsageCategory = None;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Journal Line Entry No."; Rec."Journal Line Entry No.")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the journal line entry number.';
                    Editable = false;
                    Visible = false;
                }
                field("Tag Key"; Rec."Tag Key")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the tag key for the loyalty journal line.';
                }
                field("Tag Value"; Rec."Tag Value")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the tag value for the loyalty journal line.';
                }
            }
        }
    }

    var
        JournalLineEntryNo: Integer;

    internal procedure SetJournalLineEntryNo(EntryNo: Integer)
    begin
        JournalLineEntryNo := EntryNo;
    end;

    trigger OnOpenPage()
    begin
        if JournalLineEntryNo <> 0 then begin
            Rec.FilterGroup(2);
            Rec.SetRange("Journal Line Entry No.", JournalLineEntryNo);
            Rec.FilterGroup(0);
        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if JournalLineEntryNo <> 0 then
            Rec."Journal Line Entry No." := JournalLineEntryNo;
    end;
}
