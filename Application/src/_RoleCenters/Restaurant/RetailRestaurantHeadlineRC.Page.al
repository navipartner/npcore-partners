page 6151337 "NPR Restaurant Headline RC"
{
    Extensible = False;
    Caption = 'Headline';
    PageType = HeadlinePart;
    RefreshOnActivate = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                Visible = UserGreetingVisible;
                field(GreetingText; RCHeadlinesPageCommon.GetGreetingText())
                {

                    Caption = 'Greeting headline';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Greeting headline field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Control2)
            {
                ShowCaption = false;
                Visible = DefaultFieldsVisible;
                field(DocumentationText; RCHeadlinesPageCommon.GetDocumentationText())
                {

                    Caption = 'Documentation headline';
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Documentation headline field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        HyperLink(RCHeadlinesPageCommon.DocumentationUrlTxt());
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        RCHeadlinesPageCommon.HeadlineOnOpenPage(Page::"NPR Restaurant Headline RC");
        DefaultFieldsVisible := false;
        UserGreetingVisible := RCHeadlinesPageCommon.IsUserGreetingVisible();
    end;

    var
        [InDataSet]
        DefaultFieldsVisible: Boolean;
        [InDataSet]
        UserGreetingVisible: Boolean;
        RCHeadlinesPageCommon: Codeunit "RC Headlines Page Common";
}
