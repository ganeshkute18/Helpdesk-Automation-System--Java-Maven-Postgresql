param(
    [string]$BaseUrl = "http://localhost:8080"
)

Write-Host "=== Testing API Endpoints ===" -ForegroundColor Green
Write-Host "Base URL: $BaseUrl`n" -ForegroundColor Cyan

# Test Create Ticket
Write-Host "TEST 1: Create Ticket (POST /tickets)" -ForegroundColor Yellow
$createBody = @{
    userId = 101
    category = "network"
    description = "Test ticket - cannot connect to VPN"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/tickets" `
        -Method Post `
        -ContentType 'application/json' `
        -Body $createBody
    
    Write-Host "✓ Ticket created successfully" -ForegroundColor Green
    Write-Host "  Ticket ID: $($response.ticketId)" -ForegroundColor Cyan
    Write-Host "  Status: $($response.status)" -ForegroundColor Cyan
    Write-Host "  Category: $($response.category)" -ForegroundColor Cyan
    Write-Host "  Assigned Agent ID: $($response.assignedAgentId)" -ForegroundColor Cyan
    
    $ticketId = $response.ticketId
} catch {
    Write-Host "✗ Failed to create ticket: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test Get Ticket
Write-Host "`nTEST 2: Get Ticket (GET /tickets/$ticketId)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/tickets/$ticketId" -Method Get
    Write-Host "✓ Ticket retrieved successfully" -ForegroundColor Green
    Write-Host "  Description: $($response.description)" -ForegroundColor Cyan
    Write-Host "  Created At: $($response.createdAt)" -ForegroundColor Cyan
    Write-Host "  SLA Due At: $($response.slaDueAt)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Failed to retrieve ticket: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create more test tickets with different categories
Write-Host "`nTEST 3: Create Multiple Tickets" -ForegroundColor Yellow
$categories = @("software", "hardware", "database", "security")
foreach ($category in $categories) {
    $body = @{
        userId = 102
        category = $category
        description = "Test ticket for $category"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/tickets" `
            -Method Post `
            -ContentType 'application/json' `
            -Body $body
        Write-Host "✓ Created ticket for category '$category' (ID: $($response.ticketId))" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to create ticket for category '$category'" -ForegroundColor Red
    }
}

Write-Host "`n=== All Tests Completed ===" -ForegroundColor Green
