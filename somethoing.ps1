function PostTraversal ($curNode) {
    $curId = (GetHashCode $curNode)
    if ( $curNode.GetType().Name -eq 'PipelineAst' -and $valuelog[$iexPrefix + $curNode.PipelineElements[-1].Extent.StartOffset + ',' 
          + $curNode.PipelineElements[-1].Extent.EndOffset] -eq 'Foreach-Object' -and `
            $curNode.PipelineElements[-1].CommandElements[-1].GetType().Name -eq 'ScriptBlockExpressionAst') {
        $count = $foreachCount[$iexPrefix + $curNode.PipelineElements[-1].Extent.StartOffset + ',' + $curNode.PipelineElements[-1].Extent.EndOffset]
        $BlockString = $NodeString[(GetHashCode $curNode.PipelineElements[-1].CommandElements[-1].ScriptBlock.EndBlock)]
        if ($count -eq $hookTimes -and -not $BlockString.Contains('$_')) { $NodeString[$curId] = $BlockString }
    }
    if ( $curNode.GetType().Name -eq 'FunctionDefinitionAst' ) {
        $funcDeob[$curNode.Name] = $NodeString[$curId]
        $NodeString[$curId] = $funcDef[$curNode.Name]
    }
}
