page 6150808 "NPR SaaS Import Bgn.Sess. List"
{
    Caption = 'SaaS Import Background Session List';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR SaaS Import Bgn. Session";
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ChunkId; Rec.ChunkId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'The ID of the chunk';
                }
                field(ServiceInstance; Rec.ServiceInstance)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'The ID of the BC NST';
                }
            }
        }
    }
}