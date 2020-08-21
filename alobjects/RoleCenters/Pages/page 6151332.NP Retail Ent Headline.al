page 6151332 "NP Retail Ent Headline"
{
    Caption = 'Headline';
    PageType = HeadlinePart;
    RefreshOnActivate = true;
    SourceTable = "NP Retail Entertainment Cue";

    layout
    {
        area(content)
        {

            group(Control9)
            {
                ShowCaption = false;

                field(GreetingText; GreetingText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Greeting headline';
                    Editable = false;

                }
            }


            group(Control5)
            {
                ShowCaption = false;
                field("Issued Tickets"; IssuedTicketText)
                {
                    ApplicationArea = All;

                    Editable = false;
                }
            }
            group(Control3)
            {
                ShowCaption = false;
                field("Ticket Admissions"; TicketAdmission)
                {
                    ApplicationArea = All;

                    Editable = false;
                }
            }
            group(Control6)
            {
                ShowCaption = false;
                field(Members; MembersCreated)
                {
                    ApplicationArea = All;

                    Editable = false;
                }
            }


        }
    }
    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        ComputeDefaultFieldsVisibility;
    end;

    trigger OnOpenPage()
    var
        Uninitialized: Boolean;
    begin
        if not Get then
            if WritePermission then begin
                Init;
                Insert;
            end else
                Uninitialized := true;

        if not Uninitialized and WritePermission then begin
            //"Workdate for computations" := WorkDate;
            Modify;
            HeadlineManagement.ScheduleTask(Codeunit::"RC Headlines Executor");
        end;

        HeadlineManagement.GetUserGreetingText(GreetingText);



        DocumentationText := StrSubstNo(DocumentationTxt, PRODUCTNAME.Short);

        HeadlineManagement.GetTicketAdmissionToday(TicketAdmission);
        HeadlineManagement.GetMembersCreatedToday(MembersCreated);
        HeadlineManagement.GetissuedTicketToday(IssuedTicketText);

        if Uninitialized then
            // table is uninitialized because of permission issues. OnAfterGetRecord won't be called
            ComputeDefaultFieldsVisibility;

        Commit; // not to mess up the other page parts that may do IF CODEUNIT.RUN()
    end;

    var
        HeadlineManagement: Codeunit "NP Retail Headline Management";
        DefaultFieldsVisible: Boolean;
        DocumentationTxt: Label 'Want to learn more about %1?', Comment = '%1 is the NAV short product name.';
        DocumentationUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=867580', Locked = true;
        GreetingText: Text[250];
        DocumentationText: Text[250];
        UserGreetingVisible: Boolean;
        IssuedTicketText: Text[250];
        TicketAdmission: Text[250];
        MembersCreated: Text[250];


    local procedure ComputeDefaultFieldsVisibility()
    var
        ExtensionHeadlinesVisible: Boolean;
    begin
        OnIsAnyExtensionHeadlineVisible(ExtensionHeadlinesVisible);
        DefaultFieldsVisible := not ExtensionHeadlinesVisible;
        UserGreetingVisible := HeadlineManagement.ShouldUserGreetingBeVisible;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsAnyExtensionHeadlineVisible(var ExtensionHeadlinesVisible: Boolean)
    begin
    end;

}
