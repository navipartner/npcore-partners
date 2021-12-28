report 6014425 "NPR Event Overview"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Event Overview.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Event Overview';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Date; Date)
        {
            DataItemTableView = sorting("Period Type", "Period Start");
            column(PeriodStartDate; Date."Period Start")
            {
            }
            column(ReportCaption; ReportCaptionLbl)
            {
            }
            column(Today; Format(Today()))
            {
            }
            column(PrintedBy; PrintedByLbl + UserId)
            {
            }
            column(CompanyName; CompanyName)
            {
            }
            dataitem(Job; Job)
            {
                DataItemTableView = sorting("No.");
                RequestFilterFields = "NPR Event Status";

                column(No_Job; Job."No.")
                {
                }
                column(Description_Job; Job.Description)
                {
                }
                column(BilltoName_Job; "Bill-to Name")
                {
                }
                column(StartingDate_Job; Format(Job."Starting Date"))
                {
                }
                column(EndingDate_Job; Format(Job."Ending Date"))
                {
                }
                column(Contact_Job; Job."Bill-to Contact")
                {
                }
                column(NPR_Person_Responsible_Name; Job."NPR Person Responsible Name")
                {
                }
                column(DescriptionLbl; DescriptionLbl)
                {
                }
                column(CustomerLbl; CustomerLbl)
                {
                }
                column(ContactLbl; ContactLbl)
                {
                }
                column(PersonResponsibleLbl; PersonResponsibleLbl)
                {
                }
                column(SkipJob; SkipJob)
                {
                }
                dataitem(JobPlanningLine; "Job Planning Line")
                {
                    DataItemTableView = sorting("Job No.", "Job Task No.", "Line No.");
                    column(JobNo_JobPlanningLine; JobPlanningLine."Job No.")
                    {
                    }
                    column(LineNo_JobPlanningLine; "Line No.")
                    {
                    }
                    column(Description_JobPlanningLine; JobPlanningLine.Description)
                    {
                    }
                    column(StartingTime_JobPlanningLine; Format(JobPlanningLine."NPR Starting Time"))
                    {
                    }
                    column(EndingTime_JobPlanningLine; Format(JobPlanningLine."NPR Ending Time"))
                    {
                    }
                    column(Quantity_JobPlanningLine; Quantity)
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        JobPlanningLine.SetRange("Job No.", Job."No.");
                        JobPlanningLine.SetRange("NPR Group Source Line No.", 0);
                        JobPlanningLine.SetRange("Planning Date", Date."Period Start");
                        if GetTypeFilter() then
                            JobPlanningLine.SetFilter(Type, TypeFitler);
                    end;
                }

                trigger OnPreDataItem()
                begin
                    Job.SetRange("NPR Event", true);
                    Job.SetFilter("Starting Date", '..%1', PeriodEnd);
                end;

                trigger OnAfterGetRecord()
                begin
                    if ((Date."Period Start" >= Job."Starting Date") and (Date."Period Start" <= "Ending Date")) then
                        SkipJob := false
                    else
                        SkipJob := true;
                end;
            }

            trigger OnPreDataItem()
            begin
                Date.SetRange("Period Start", PeriodStart, PeriodEnd);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Period Start"; PeriodStart)
                    {
                        Caption = 'Period starts at';
                        ToolTip = 'Specifies the value of the Period starts at field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Period End"; PeriodEnd)
                    {
                        Caption = 'Period ends at';
                        ToolTip = 'Specifies the value of the Period ends at field';
                        ApplicationArea = NPRRetail;
                    }
                    group(JobPlanningType)
                    {
                        Caption = 'Type';
                        field("Job Planning Type Resource"; JobPlanningTypeResource)
                        {
                            Caption = 'Resource';
                            ToolTip = 'Specifies the value of the Resource field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Job Planning Type Item"; JobPlanningTypeItem)
                        {
                            Caption = 'Item';
                            ToolTip = 'Specifies the value of the Item field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Job Planning Type GL Account"; JobPlanningTypeGLAccount)
                        {
                            Caption = 'G/L Account';
                            ToolTip = 'Specifies the value of the G/L Account field';
                            ApplicationArea = NPRRetail;
                        }
                        field("Job Planning Type Text"; JobPlanningTypeText)
                        {
                            Caption = 'Text';
                            ToolTip = 'Specifies the value of the Text field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
        }
    }

    local procedure GetTypeFilter(): Boolean
    begin
        TypeFitler := '';

        if JobPlanningTypeResource then
            IncreaseTypeFitler(Format(JobPlanningLineType::Resource));
        if JobPlanningTypeItem then
            IncreaseTypeFitler(Format(JobPlanningLineType::Item));
        if JobPlanningTypeGLAccount then
            IncreaseTypeFitler(Format(JobPlanningLineType::"G/L Account"));
        if JobPlanningTypeText then
            IncreaseTypeFitler(Format(JobPlanningLineType::Text));

        exit(TypeFitler <> '');
    end;

    local procedure IncreaseTypeFitler(IncreaseText: Text)
    begin
        if TypeFitler = '' then
            TypeFitler += IncreaseText
        else
            TypeFitler += '|' + IncreaseText;
    end;

    var
        JobPlanningLineType: Enum "Job Planning Line Type";
        PeriodEnd: Date;
        PeriodStart: Date;
        TypeFitler: Text;
        JobPlanningTypeResource: Boolean;
        JobPlanningTypeItem: Boolean;
        JobPlanningTypeGLAccount: Boolean;
        JobPlanningTypeText: Boolean;
        SkipJob: Boolean;
        ReportCaptionLbl: Label 'Event Overview';
        PrintedByLbl: Label 'Printed by ';
        DescriptionLbl: Label 'Description';
        CustomerLbl: Label 'Customer';
        ContactLbl: Label 'Contact';
        PersonResponsibleLbl: Label 'Person Responsible';
}

