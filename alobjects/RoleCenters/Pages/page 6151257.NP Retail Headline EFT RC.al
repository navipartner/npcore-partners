page 6151257 "NP Retail Headline EFT RC"
{
    Caption = 'Headline';
    // PageType = HeadlinePart;
    RefreshOnActivate = true;
    SourceTable = "RC Headlines User Data";

    layout
    {
        area(content)
        {

            group(Control9)
            {
                ShowCaption = false;
                Visible = UserGreetingVisible;
                field(GreetingText; GreetingText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Greeting headline';
                    Editable = false;
                    Visible = UserGreetingVisible;
                }
            }

            group(Control7)
            {
                ShowCaption = false;
                Visible = DefaultFieldsVisible;
                field(DocumentationText; DocumentationText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Documentation headline';
                    DrillDown = true;
                    Editable = false;
                    Visible = DefaultFieldsVisible;

                    trigger OnDrillDown()
                    begin

                        HyperLink(DocumentationUrlTxt);
                    end;
                }
            }

            group(Control5)
            {
                ShowCaption = false;
                field(MyPickText; MyPickText)
                {
                    Caption = 'My Pick Text';
                    Editable = false;
                }
            }
            group(Control3)
            {
                ShowCaption = false;
                field(AwayPickText; AwayPickText)
                {
                    Caption = 'Away Pick Text';
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
            "User workdate" := WorkDate;
            Modify;
            HeadlineManagement.ScheduleTask(Codeunit::"Headlines");
        end;

        HeadlineManagement.GetUserGreetingText(GreetingText);



        DocumentationText := StrSubstNo(DocumentationTxt, PRODUCTNAME.Short);


        HeadlineManagement.GetMyPutAwayToday(AwayPickText);
        HeadlineManagement.GetTopSalesToday(MyPickText);

        MyPickText := 'My Picks is ' + MyPickText;
        // + ' ' +MyPickText;
        AwayPickText := 'Put Aways is ' + AwayPickText;
        // + ' ' + AwayPickText;

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
        MyPickText: Text[250];
        AwayPickText: Text[250];
        HighestSalesTxt: Label 'Highest Sales Today is';
        TopSalesPersonTxt: Label 'Top Sales person today is ';

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

