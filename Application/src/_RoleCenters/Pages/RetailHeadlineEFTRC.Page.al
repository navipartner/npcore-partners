page 6151257 "NPR Retail Headline EFT RC"
{
    Extensible = False;
    UsageCategory = None;
    Caption = 'Headline';
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

                    Caption = 'Greeting headline';
                    Editable = false;
                    Visible = UserGreetingVisible;
                    ToolTip = 'Specifies the value of the Greeting headline field';
                    ApplicationArea = NPRRetail;
                }
            }

            group(Control7)
            {
                ShowCaption = false;
                Visible = DefaultFieldsVisible;
                field(DocumentationText; DocumentationText)
                {

                    Caption = 'Documentation headline';
                    DrillDown = true;
                    Editable = false;
                    Visible = DefaultFieldsVisible;
                    ToolTip = 'Specifies the value of the Documentation headline field';
                    ApplicationArea = NPRRetail;

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
                    ToolTip = 'Specifies the value of the My Pick Text field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Control3)
            {
                ShowCaption = false;
                field(AwayPickText; AwayPickText)
                {

                    Caption = 'Away Pick Text';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Away Pick Text field';
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

        if not Uninitialized and Rec.WritePermission then begin
            Rec."User workdate" := WorkDate();
            Rec.Modify();
        end;

        HeadlineManagement.GetUserGreetingText(GreetingText);



        DocumentationText := StrSubstNo(DocumentationTxt, PRODUCTNAME.Short());


        HeadlineManagement.GetMyPutAwayToday(AwayPickText);
        HeadlineManagement.GetTopSalesToday(MyPickText);

        MyPickText := 'My Picks is ' + MyPickText;
        AwayPickText := 'Put Aways is ' + AwayPickText;

        if Uninitialized then
            // table is uninitialized because of permission issues. OnAfterGetRecord won't be called
            ComputeDefaultFieldsVisibility();

        Commit(); // not to mess up the other page parts that may do IF CODEUNIT.RUN()
    end;

    var
        HeadlineManagement: Codeunit "NPR NP Retail Headline Mgt.";
        DefaultFieldsVisible: Boolean;
        DocumentationTxt: Label 'Want to learn more about %1?', Comment = '%1 is the NAV short product name.';
        DocumentationUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=867580', Locked = true;
        GreetingText: Text;
        DocumentationText: Text;
        UserGreetingVisible: Boolean;
        MyPickText: Text;
        AwayPickText: Text;

    local procedure ComputeDefaultFieldsVisibility()
    var
        ExtensionHeadlinesVisible: Boolean;
    begin
        OnIsAnyExtensionHeadlineVisible(ExtensionHeadlinesVisible);
        DefaultFieldsVisible := not ExtensionHeadlinesVisible;
        UserGreetingVisible := HeadlineManagement.ShouldUserGreetingBeVisible();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsAnyExtensionHeadlineVisible(var ExtensionHeadlinesVisible: Boolean)
    begin
    end;
}

