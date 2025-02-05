﻿page 6151332 "NPR Retail Ent Headline"
{
    Extensible = False;
    Caption = 'Headline';
    PageType = HeadlinePart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Entertainment Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            group(Control5)
            {
                ShowCaption = false;
                field("Issued Tickets"; IssuedTicketText)
                {


                    Editable = false;
                    ToolTip = 'Specifies the number of the issued tickets.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Control3)
            {
                ShowCaption = false;
                field("Ticket Admissions"; TicketAdmission)
                {


                    Editable = false;
                    ToolTip = 'Specifies the number of the ticket admissions.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Control6)
            {
                ShowCaption = false;
                field(Members; MembersCreated)
                {


                    Editable = false;
                    ToolTip = 'Specifies the number of the members created.';
                    ApplicationArea = NPRRetail;
                }
            }


        }
    }
    trigger OnAfterGetRecord()
    begin
        ComputeDefaultFieldsVisibility();
    end;

    trigger OnOpenPage()
    var
        Uninitialized: Boolean;
    begin
        if not Rec.Get() then
            if Rec.WritePermission then begin
                Rec.Init();
                Rec.Insert();
            end else
                Uninitialized := true;

        if not Uninitialized and Rec.WritePermission then
            Rec.Modify();

        HeadlineManagement.GetUserGreetingText(GreetingText);



        DocumentationText := StrSubstNo(DocumentationTxt, PRODUCTNAME.Short());

        HeadlineManagement.GetTicketAdmissionToday(TicketAdmission);
        HeadlineManagement.GetMembersCreatedToday(MembersCreated);
        HeadlineManagement.GetissuedTicketToday(IssuedTicketText);

        if Uninitialized then
            // table is uninitialized because of permission issues. OnAfterGetRecord won't be called
            ComputeDefaultFieldsVisibility();

        Commit(); // not to mess up the other page parts that may do IF CODEUNIT.RUN()
    end;

    var
        HeadlineManagement: Codeunit "NPR NP Retail Headline Mgt.";
        DocumentationTxt: Label 'Want to learn more about %1?', Comment = '%1 is the BC short product name.';
        GreetingText: Text;
        DocumentationText: Text[250];
        IssuedTicketText: Text[250];
        TicketAdmission: Text[250];
        MembersCreated: Text[250];


    local procedure ComputeDefaultFieldsVisibility()
    var
        ExtensionHeadlinesVisible: Boolean;
    begin
        OnIsAnyExtensionHeadlineVisible(ExtensionHeadlinesVisible);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsAnyExtensionHeadlineVisible(var ExtensionHeadlinesVisible: Boolean)
    begin
    end;

}
