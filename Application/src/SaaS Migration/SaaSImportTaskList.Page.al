page 6150809 "NPR SaaS Import Task List"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR SaaS Import Task";
    Caption = 'SaaS Import Task List';
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
            }
        }
    }
}