codeunit 6060058 "NPR Item Wksht. TaskQueue Mgt."
{
    TableNo = "NPR Task Line";
    trigger OnRun()
    var
        Register: Boolean;
        BatchName: Text;
        TemplateName: Text;
    begin
        TemplateName := UpperCase(GetParameterText('TEMPLATE_NAME'));
        BatchName := UpperCase(GetParameterText('BATCH_NAME'));
        Register := GetParameterBool('REGISTER_ITEM_WKSHT');

        Commit;
        if Register then
            RegisterItemWkshtBatch(TemplateName, BatchName);
    end;

    local procedure RegisterItemWkshtBatch(TemplateName: Text; BatchName: Text)
    var
        ItemWkshtLine: Record "NPR Item Worksheet Line";
    begin
        ItemWkshtLine.FilterGroup(2);
        ItemWkshtLine.SetRange("Worksheet Template Name", TemplateName);
        ItemWkshtLine.SetRange("Worksheet Name", BatchName);
        ItemWkshtLine.FilterGroup(0);

        if ItemWkshtLine.IsEmpty then
            exit;

        CODEUNIT.Run(CODEUNIT::"NPR Item Wsht.-Regist. Batch", ItemWkshtLine);
    end;
}

