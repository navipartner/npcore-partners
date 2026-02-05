page 6150753 "NPR HL HeyLoyalty Members"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = true;
    Caption = 'HeyLoyalty Members';
    PageType = List;
    Editable = false;
    SourceTable = "NPR HL HeyLoyalty Member";
    UsageCategory = Lists;
    ApplicationArea = NPRHeyLoyalty;
    PromotedActionCategories = 'Manage,Process,Report,Sync,Navigate';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ToolTip = 'Specifies the value of the Middle Name field.';
                    ApplicationArea = NPRHeyLoyalty;
                    Visible = false;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field(Gender; Rec.Gender)
                {
                    ToolTip = 'Specifies the value of the Gender field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field(Birthday; Rec.Birthday)
                {
                    ToolTip = 'Specifies the value of the Birthday field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    ToolTip = 'Specifies the value of the ZIP Code field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ToolTip = 'Specifies the value of the Country Code field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the store code assigned to the member.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("HL Store Name"; Rec."HL Store Name")
                {
                    ToolTip = 'Specifies HeyLoyalty name of the store assigned to the member.';
                    ApplicationArea = NPRHeyLoyalty;
                    Visible = false;
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the external number assigned to the member memberhip.';
                }
                field("Membership Item No."; Rec."Membership Item No.")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the item number used for the last membership period.';
                    Visible = false;
                }
                field("Membership Issued On"; Rec."Membership Issued On")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the date when the member membership was first activated on.';
                }
                field("Membership Valid Until"; Rec."Membership Valid Until")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the member membership expiration date.';
                }
                field("No. of Attributes"; Rec."No. of Attributes")
                {
                    ToolTip = 'Specifies number of additional attributes assigned to the HeyLoyalty member record.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("No. of MultiChoice Fld Options"; Rec.NoOfAssignedMCFieldOptions())
                {
                    Caption = 'No. of MultiChoice Fld Options';
                    ToolTip = 'Specifies number of HeyLoyalty multiple choice field option values assigned to the HeyLoyalty member record.';
                    ApplicationArea = NPRHeyLoyalty;
                    Editable = false;
                    Visible = ShowNoOfMCFOptions;

                    trigger OnAssistEdit()
                    begin
                        Rec.ShowAssigneMCFOptions();
                    end;
                }
                field("HeyLoyalty Id"; Rec."HeyLoyalty Id")
                {
                    ToolTip = 'Specifies the value of the HeyLoyalty Id field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("HL Member Status"; Rec."HL Member Status")
                {
                    ToolTip = 'Specifies the value of the HeyLoyalty Member Status field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("HL E-mail Status"; Rec."HL E-mail Status")
                {
                    ToolTip = 'Specifies the value of the HeyLoyalty E-mail Status field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Unsubscribed at"; Rec."Unsubscribed at")
                {
                    ToolTip = 'Specifies the value of the Unsubscribed at field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    ToolTip = 'Specifies the value of the Member Entry No. field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ToolTip = 'Specifies the value of the Membership Entry No. field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Member Created Datetime"; Rec."Member Created Datetime")
                {
                    ToolTip = 'Specifies the value of the Member Created Datetime field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Created from HeyLoyalty"; Rec."Created from HeyLoyalty")
                {
                    ToolTip = 'Specifies whether the member was initially created in HeyLoyalty.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Member Anonymized"; Rec.Anonymized)
                {
                    ToolTip = 'Specifies the value of the Member Anonymized field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Member Deleted"; Rec.Deleted)
                {
                    ToolTip = 'Specifies the value of the Member Deleted field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field("Update from HL Error"; Rec."Update from HL Error")
                {
                    ToolTip = 'Specifies if last update from HeyLoyalty has failed.';
                    ApplicationArea = NPRHeyLoyalty;
                }
                field(LastErrorMessage; LastErrorMessage)
                {
                    Caption = 'Last Error Message';
                    ToolTip = 'Specifies the error message text, if the last update from HeyLoyalty has failed.';
                    ApplicationArea = NPRHeyLoyalty;
                    Editable = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRHeyLoyalty;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowErrorMessage)
            {
                Caption = 'Show Error';
                ToolTip = 'Shows the error message text, if the last update from HeyLoyalty has failed for the record.';
                ApplicationArea = NPRHeyLoyalty;
                Image = PrevErrorMessage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.TestField("Update from HL Error");
                    Message(Rec.GetErrorMessage());
                end;
            }
            action(ReprocessSelectedFailedUpdates)
            {
                Caption = 'Reprocess Failed';
                ToolTip = 'Executes another attempt to update members with information received previously from HeyLoyalty for selected records on the page.';
                ApplicationArea = NPRHeyLoyalty;
                Image = NegativeLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    HLMember: Record "NPR HL HeyLoyalty Member";
                begin
                    CurrPage.SetSelectionFilter(HLMember);
                    Codeunit.Run(Codeunit::"NPR HL Upsert Member Batch", HLMember);
                    CurrPage.Update(false);
                end;
            }
            action(GetDataFromHeyLoyalty)
            {
                Caption = 'Update from HeyLoyalty';
                ToolTip = 'Updates selected records with information from HeyLoyalty.';
                ApplicationArea = NPRHeyLoyalty;
                Image = ImportDatabase;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;

                trigger OnAction()
                var
                    HLMember: Record "NPR HL HeyLoyalty Member";
                    UpdateMemberFromHL: Codeunit "NPR HL Update Member from HL";
                begin
                    CurrPage.SetSelectionFilter(HLMember);
                    UpdateMemberFromHL.UpdateMembersFromHL(HLMember);
                    CurrPage.Update(false);
                end;
            }
            action(DeleteRec)
            {
                Caption = 'Delete';
                ToolTip = 'Delete the selected row.';
                ApplicationArea = NPRHeyLoyalty;
                ShortcutKey = 'Ctrl+Del';
                Image = Delete;
                Promoted = true;
                PromotedCategory = New;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    if Rec."Member Entry No." = 0 then
                        Rec.Deleted := true;
                    Rec.TestField(Deleted);
                    Rec.Delete(true);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenMember)
            {
                Caption = 'Member';
                ToolTip = 'Open related member card.';
                ApplicationArea = NPRHeyLoyalty;
                Image = CustomerContact;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Member: Record "NPR MM Member";
                begin
                    Rec.TestField("Member Entry No.");
                    Rec.TestField(Deleted, false);
                    Member.Get(Rec."Member Entry No.");
                    Member.SetRecFilter();
                    Page.Run(Page::"NPR MM Member Card", Member);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        HLMultiChoiceField: Record "NPR HL MultiChoice Field";
    begin
        ShowNoOfMCFOptions := not HLMultiChoiceField.IsEmpty();
    end;

    trigger OnAfterGetRecord()
    begin
        LastErrorMessage := Rec.GetErrorMessage();
    end;

    var
        LastErrorMessage: Text;
        ShowNoOfMCFOptions: Boolean;
}