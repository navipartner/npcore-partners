report 6014451 "NPR TM Ticket Acc. Stat. Mtrx"
{
#if (BC17 or BC18 or BC19)
    UsageCategory = None;
#else
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    Caption = 'Ticket Access Statistics Matrix Excel';
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = "Excel Layout";
    Extensible = true;

    dataset
    {
        dataitem(TicketAccessStats; "NPR TM Ticket Access Stats")
        {
            column(EntryNo; "Entry No.")
            {
            }
            column(ItemNo; "Item No.")
            {
            }
            column(Name; Name)
            {
            }
            column(VariantCode; "Variant Code")
            {
            }
            column(TicketType; "Ticket Type")
            {
            }
            column(AdmissionCode; "Admission Code")
            {
            }
            column(AdmissionDate; "Admission Date")
            {
            }
            column(AdmissionHour; "Admission Hour")
            {
            }
            column(AdmissionCount; "Admission Count")
            {
            }
            column(AdmissionCountNeg; "Admission Count (Neg)")
            {
            }
            column(AdmissionCountReEntry; "Admission Count (Re-Entry)")
            {
            }
            column(GeneratedCountPos; "Generated Count (Pos)")
            {
            }
            column(GeneratedCountNeg; "Generated Count (Neg)")
            {
            }
            column(HighestAccessEntryNo; "Highest Access Entry No.")
            {
            }
            column(SumAdmissionCount; "Sum Admission Count")
            {
            }
            column(SumAdmissionCountNeg; "Sum Admission Count (Neg)")
            {
            }
            column(SumAdmissionCountReEntry; "Sum Admission Count (Re-Entry)")
            {
            }
            column(SumGeneratedCountPos; "Sum Generated Count (Pos)")
            {
            }
            column(SumGeneratedCountNeg; "Sum Generated Count (Neg)")
            {
            }
            trigger OnAfterGetRecord()
            var
                Item: Record Item;
            begin
                Name := '';
                if Item.Get("Item No.") then
                    Name := Item.Description;
                TicketAccessStats.CalcFields("Sum Admission Count", "Sum Admission Count (Neg)", "Sum Admission Count (Re-Entry)", "Sum Admission Count (Re-Entry)", "Sum Generated Count (Pos)");
            end;
        }
    }

    rendering
    {
        layout("Excel Layout")
        {
            Caption = 'Excel layout to display and work with data from table NPR TM Ticket Access Stats.';
            LayoutFile = './src/_Reports/layouts/TM Ticket Access Statistics Matrix.xlsx';
            Type = Excel;
        }
    }

    var
        Name: Text;
#endif
}
