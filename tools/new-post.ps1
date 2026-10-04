param (
    [Parameter(Mandatory=$true)]
    [string]$Title
)

# Convert title to URL slug
$slug = $Title.ToLower() -replace '[^\w\s-]', '' -replace '\s+', '-'
$date = Get-Date -Format "yyyy-MM-dd"
$filename = "_posts/$date-$slug.md"

# Chirpy Front Matter Template
$content = @"
---
title: "$Title"
date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
categories: [BLOG]
tags: []
---

"@

# Ensure _posts directory exists and create file
if (-not (Test-Path "_posts")) {
    New-Item -ItemType Directory -Path "_posts" | Out-Null
}

$content | Out-File -FilePath $filename -Encoding utf8
Write-Host "Created post: $filename" -ForegroundColor Green