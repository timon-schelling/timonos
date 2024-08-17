def gitlog [n: int] {
    git log --pretty=%h»¦«%s»¦«%aN»¦«%aE»¦«%aD -n $n |
    lines |
    split column "»¦«" commit subject name email date |
    upsert date {|d| $d.date | into datetime} |
    sort-by date
}
