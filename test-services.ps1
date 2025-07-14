# Test services PowerShell script

# Helper function to make HTTP requests with error handling
function Invoke-ServiceRequest {
    param (
        [string]$Uri,
        [string]$Method = "GET",
        [string]$Body = $null,
        [string]$ContentType = "application/json",
        [string]$AuthToken = $null,
        [string]$ServiceName = "Service"
    )

    $headers = @{}
    if ($AuthToken) {
        $headers["Authorization"] = "Bearer $AuthToken"
    }

    try {
        if ($Body) {
            $response = Invoke-WebRequest -Uri $Uri -Method $Method -Body $Body -ContentType $ContentType -Headers $headers
        } else {
            $response = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $headers
        }
        
        Write-Host "$ServiceName request successful!" -ForegroundColor Green
        Write-Host "Response:" -ForegroundColor Cyan
        $response.Content | ConvertFrom-Json | Format-List
        return $response
    } catch {
        Write-Host "$ServiceName request failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response body: $responseBody" -ForegroundColor Red
        }
        return $null
    }
}

# Test Service Registry (Eureka)
Write-Host "`n=== Testing Service Registry (Eureka) ===" -ForegroundColor Green
Write-Host "`nChecking Eureka status..." -ForegroundColor Yellow
$eurekaResponse = Invoke-ServiceRequest -Uri "http://localhost:8761/eureka/apps" `
    -ServiceName "Eureka"

# Test Config Server
Write-Host "`n=== Testing Config Server ===" -ForegroundColor Green
Write-Host "`nChecking auth-service config..." -ForegroundColor Yellow
$configResponse = Invoke-ServiceRequest -Uri "http://localhost:8888/auth-service/default" `
    -ServiceName "Config Server"

# Test Auth Service
Write-Host "`n=== Testing Auth Service ===" -ForegroundColor Green

# Generate random username and email to avoid conflicts
$random = Get-Random
$username = "testuser_$random"
$email = "testuser_$random@example.com"

# Test user registration
$registrationBody = @{
    username = $username
    email = $email
    password = "Test123!"
    fullName = "Test User"
    role = "USER"
} | ConvertTo-Json

Write-Host "`nTesting registration endpoint..." -ForegroundColor Yellow
Write-Host "Using test credentials:" -ForegroundColor Gray
Write-Host "Username: $username" -ForegroundColor Gray
Write-Host "Email: $email" -ForegroundColor Gray
Write-Host "Password: Test123!" -ForegroundColor Gray

$registrationResponse = Invoke-ServiceRequest -Uri "http://localhost:8080/api/auth/register" `
    -Method "Post" `
    -Body $registrationBody `
    -ServiceName "Registration"

# Extract userId (UUID string) from registration response
if ($registrationResponse) {
    $registrationContent = $registrationResponse.Content | ConvertFrom-Json
    $userId = $registrationContent.userId
    $registeredUsername = $registrationContent.username
    $registeredEmail = $registrationContent.email

    # Test user login
    $loginBody = @{
        username = $username
        password = "Test123!"
    } | ConvertTo-Json

    Write-Host "`nTesting login endpoint..." -ForegroundColor Yellow
    $loginResponse = Invoke-ServiceRequest -Uri "http://localhost:8080/api/auth/login" `
        -Method "Post" `
        -Body $loginBody `
        -ServiceName "Login"

    if ($loginResponse) {
        $loginContent = $loginResponse.Content | ConvertFrom-Json
        $token = $loginContent.accessToken
        Write-Host "`nJWT Token:" -ForegroundColor Yellow
        Write-Host $token -ForegroundColor Gray
        $headers = @{"Authorization" = "Bearer $token"}
    }
}

Write-Host "`nTests completed!" -ForegroundColor Cyan

Write-Host "`n=== Testing User Service ===" -ForegroundColor Green
try {
    # Check if user already exists in User Service before creating
    Write-Host "Checking if user already exists in User Service..." -ForegroundColor Yellow
    $existingUserResponse = $null
    try {
        $existingUserResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8082/api/users/username/$registeredUsername" -Headers $headers
    } catch {
        # If not found, $existingUserResponse stays $null
    }
    if (-not $existingUserResponse) {
        # Create user in User Service only if not found
        $currentTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        $createUserBody = @{
            userId = $userId
            username = $registeredUsername
            email = $registeredEmail
            password = "password123"
            fullName = "Test User"
            role = "USER"
            isPrivate = $false
            isVerified = $false
            isActive = $true
            createdAt = $currentTime
            updatedAt = $currentTime
            bio = ""
            location = ""
            profileImageUrl = ""
            stats = @{
                postsCount = 0
                followersCount = 0
                followingCount = 0
                updatedAt = $currentTime
            }
        } | ConvertTo-Json -Depth 10

        Write-Host "Creating user in User Service..." -ForegroundColor Yellow
        $createUserResponse = Invoke-RestMethod -Method Post -Uri "http://localhost:8082/api/users" `
            -Headers $headers -Body $createUserBody -ContentType 'application/json'
        Write-Host "User created successfully in User Service" -ForegroundColor Green
        Start-Sleep -Seconds 2  # Add a small delay to ensure the user is created
    } else {
        Write-Host "User already exists in User Service, skipping creation." -ForegroundColor Yellow
    }

    # Now fetch the user profile by username (or by userId if supported)
    Write-Host "Fetching user profile..." -ForegroundColor Yellow
    $userResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8082/api/users/username/$registeredUsername" `
        -Headers $headers
    Write-Host "User profile fetched successfully" -ForegroundColor Green
    Write-Host "User ID: $($userResponse.id)" -ForegroundColor Yellow

    # Update user profile with all required fields
    $currentTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $updateProfileBody = @{
        userId = $userId
        username = $registeredUsername
        email = $registeredEmail
        fullName = "Updated Test User"
        bio = "This is a test bio"
        location = "Test Location"
        profileImageUrl = "https://example.com/test.jpg"
        role = "USER"
        isPrivate = $false
        isVerified = $false
        password = "password123"
        createdAt = $userResponse.createdAt
        updatedAt = $currentTime
    } | ConvertTo-Json

    Write-Host "Updating profile..." -ForegroundColor Yellow
    $updateResponse = Invoke-RestMethod -Method Put -Uri "http://localhost:8082/api/users/$($userResponse.id)" `
        -Headers $headers -Body $updateProfileBody -ContentType 'application/json'
    Write-Host "Profile updated successfully" -ForegroundColor Green
    Write-Host "Updated profile details: $($updateResponse | ConvertTo-Json)" -ForegroundColor Green

    # Test getting celebrity profiles
    Write-Host "Testing celebrity profile endpoints..." -ForegroundColor Yellow
    $celebritiesResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8082/api/users/celebrities" `
        -Headers $headers
    Write-Host "Found $($celebritiesResponse.Count) celebrity profiles" -ForegroundColor Green

} catch {
    Write-Host "User Service error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response details: $($_.Exception.Response.StatusCode.value__) - $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n=== Testing Post Service ===" -ForegroundColor Green
try {
    # Create a new post
    $createPostBody = @{
        title = "Test Post from Post Service $(Get-Random)"
        content = "This is a test post content for the API."
        celebrationType = "OTHER"
        userId = $userId
        mediaUrls = @()
    } | ConvertTo-Json

    Write-Host "Creating post..." -ForegroundColor Yellow
    $postResponse = Invoke-RestMethod -Method Post -Uri "http://localhost:8083/api/posts" `
        -Headers $headers -Body $createPostBody -ContentType 'application/json'
    Write-Host "Post created successfully" -ForegroundColor Green

    # Get posts
    $postsResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8083/api/posts" `
        -Headers $headers
    Write-Host "Posts fetched successfully" -ForegroundColor Green
} catch {
    Write-Host "Post Service error: $_" -ForegroundColor Red
}

Write-Host "`n=== Testing Rating & Review Service ===" -ForegroundColor Green
try {
    # First, let's get a post ID to use for testing
    Write-Host "Getting a post ID for testing..." -ForegroundColor Yellow
    $postsResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8083/api/posts" -Headers $headers
    if ($postsResponse -and $postsResponse.Count -gt 0) {
        $testPostId = $postsResponse[0].id
        Write-Host "Using post ID: $testPostId" -ForegroundColor Cyan
    } else {
        # If no posts exist, create one first
        Write-Host "No posts found, creating a test post..." -ForegroundColor Yellow
        $createPostBody = @{
            title = "Test Post for Rating Review $(Get-Random)"
            content = "This is a test post for rating and review testing."
            celebrationType = "OTHER"
            userId = $userId
            mediaUrls = @()
        } | ConvertTo-Json

        $postResponse = Invoke-RestMethod -Method Post -Uri "http://localhost:8083/api/posts" `
            -Headers $headers -Body $createPostBody -ContentType 'application/json'
        $testPostId = $postResponse.id
        Write-Host "Created test post with ID: $testPostId" -ForegroundColor Cyan
    }

    # Test creating a review
    $reviewHeaders = @{
        "X-User-ID" = $userId
        "Content-Type" = "application/json"
    }
    $reviewBody = @{
        postId = $testPostId
        content = "This is a test review content with more than 10 characters to meet the validation requirement."
    } | ConvertTo-Json

    Write-Host "Creating review..." -ForegroundColor Yellow
    $reviewResponse = Invoke-RestMethod -Method Post -Uri "http://localhost:8093/api/reviews" -Headers $reviewHeaders -Body $reviewBody
    Write-Host "Review created successfully!" -ForegroundColor Green
    Write-Host "Review ID: $($reviewResponse.id)" -ForegroundColor Cyan

    # Test getting reviews for the post
    Write-Host "Getting reviews for post..." -ForegroundColor Yellow
    $getReviewsResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8093/api/reviews/posts/$testPostId" -Headers $headers
    Write-Host "Reviews fetched successfully!" -ForegroundColor Green
    Write-Host "Found $($getReviewsResponse.Count) reviews" -ForegroundColor Cyan

    # Test getting review count
    Write-Host "Getting review count..." -ForegroundColor Yellow
    $reviewCountResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8093/api/reviews/posts/$testPostId/count" -Headers $headers
    Write-Host "Review count: $reviewCountResponse" -ForegroundColor Green

    # Test creating a rating
    $ratingBody = @{
        postId = [long]$testPostId
        ratingValue = 5
    } | ConvertTo-Json

    Write-Host "Creating rating..." -ForegroundColor Yellow
    $ratingResponse = Invoke-RestMethod -Method Post -Uri "http://localhost:8093/api/ratings" -Headers $reviewHeaders -Body $ratingBody
    Write-Host "Rating created successfully!" -ForegroundColor Green
    Write-Host "Rating ID: $($ratingResponse.id)" -ForegroundColor Cyan

    # Test getting average rating
    Write-Host "Getting average rating..." -ForegroundColor Yellow
    $avgRatingResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8093/api/ratings/posts/$testPostId/average" -Headers $headers
    Write-Host "Average rating: $avgRatingResponse" -ForegroundColor Green

    # Test getting rating count
    Write-Host "Getting rating count..." -ForegroundColor Yellow
    $ratingCountResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8093/api/ratings/posts/$testPostId/count" -Headers $headers
    Write-Host "Rating count: $ratingCountResponse" -ForegroundColor Green

} catch {
    Write-Host "Rating & Review Service error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd()
        Write-Host "Status code: $statusCode" -ForegroundColor Red
        Write-Host "Response body: $responseBody" -ForegroundColor Red
        
        if ($statusCode -eq 404) {
            Write-Host "`nNote: 404 error indicates the Rating & Review Service might not be running on port 8093." -ForegroundColor Yellow
            Write-Host "Please ensure the service is started and accessible." -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== Testing Messaging Service ===" -ForegroundColor Green
try {
    # Send a message
    $messageBody = @{
        recipientId = "2"
        content = "This is a test message"
    } | ConvertTo-Json

    Write-Host "Sending message..." -ForegroundColor Yellow
    $messageResponse = Invoke-RestMethod -Method Post -Uri "http://localhost:8084/api/messages" `
        -Headers $headers -Body $messageBody
    Write-Host "Message sent successfully" -ForegroundColor Green

    # Get conversations
    $conversationsResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8084/api/messages/conversations" `
        -Headers $headers
    Write-Host "Conversations fetched successfully" -ForegroundColor Green
} catch {
    Write-Host "Messaging Service error: $_" -ForegroundColor Red
}

Write-Host "`n=== Testing Notifications Service ===" -ForegroundColor Green
try {
    Write-Host "Fetching notifications..." -ForegroundColor Yellow
    $notificationsResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8087/api/notifications" `
        -Headers $headers
    Write-Host "Notifications fetched successfully" -ForegroundColor Green

    # Mark notification as read
    $markReadResponse = Invoke-RestMethod -Method Put -Uri "http://localhost:8087/api/notifications/1/read" `
        -Headers $headers
    Write-Host "Notification marked as read" -ForegroundColor Green
} catch {
    Write-Host "Notifications Service error: $_" -ForegroundColor Red
}

Write-Host "`n=== Testing Moderation Service ===" -ForegroundColor Green
try {
    # Report content
    $reportBody = @{
        contentId = "1"
        contentType = "POST"
        reason = "TEST_REPORT"
        description = "This is a test report"
    } | ConvertTo-Json

    Write-Host "Reporting content..." -ForegroundColor Yellow
    $reportResponse = Invoke-RestMethod -Method Post -Uri "http://localhost:8089/api/moderation/reports" `
        -Headers $headers -Body $reportBody
    Write-Host "Content reported successfully" -ForegroundColor Green

    # Get reports
    $getReportsResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8089/api/moderation/reports" `
        -Headers $headers
    Write-Host "Reports fetched successfully" -ForegroundColor Green
} catch {
    Write-Host "Moderation Service error: $_" -ForegroundColor Red
}

# === Testing Awards Service ===
Write-Host "`n=== Testing Awards Service ===" -ForegroundColor Green

# First, test the GET endpoint which should work without authentication
Write-Host "Testing GET awards endpoint (should work without auth)..." -ForegroundColor Yellow
try {
    $awardsGetResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8089/api/v1/awards"
    Write-Host "Awards fetched successfully!" -ForegroundColor Green
    Write-Host "Found $($awardsGetResponse.Count) awards" -ForegroundColor Cyan
} catch {
    Write-Host "Awards Service GET error: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $reader.BaseStream.Position = 0
        $reader.DiscardBufferedData()
        $responseBody = $reader.ReadToEnd()
        Write-Host "Status code: $statusCode" -ForegroundColor Red
        Write-Host "Response body: $responseBody" -ForegroundColor Red
    }
}

# Test POST endpoint with admin user (this may fail due to JWT role issues)
Write-Host "`nTesting POST awards endpoint (requires ADMIN role)..." -ForegroundColor Yellow

# Register and login as ADMIN for Awards Service
$adminUsername = "admin_$(Get-Random)"
$adminEmail = "$adminUsername@example.com"
$adminPassword = "Admin123!"

$adminRegistrationBody = @{
    username = $adminUsername
    email = $adminEmail
    password = $adminPassword
    fullName = "Admin User"
    role = "ADMIN"
} | ConvertTo-Json

Write-Host "Registering ADMIN user for Awards Service..." -ForegroundColor Yellow
$adminRegResponse = Invoke-ServiceRequest -Uri "http://localhost:8080/api/auth/register" -Method "Post" -Body $adminRegistrationBody -ServiceName "Awards Admin Registration"

$adminToken = $null
if ($adminRegResponse) {
    $adminLoginBody = @{
        username = $adminUsername
        password = $adminPassword
    } | ConvertTo-Json
    Write-Host "Logging in as ADMIN user for Awards Service..." -ForegroundColor Yellow
    $adminLoginResponse = Invoke-ServiceRequest -Uri "http://localhost:8080/api/auth/login" -Method "Post" -Body $adminLoginBody -ServiceName "Awards Admin Login"
    if ($adminLoginResponse) {
        $adminLoginContent = $adminLoginResponse.Content | ConvertFrom-Json
        # Try both 'token' and 'accessToken' for compatibility
        if ($adminLoginContent.token) {
            $adminToken = $adminLoginContent.token
        } elseif ($adminLoginContent.accessToken) {
            $adminToken = $adminLoginContent.accessToken
        } else {
            Write-Host "Could not find JWT in login response. Full response:" -ForegroundColor Red
            $adminLoginContent | ConvertTo-Json | Write-Host
        }
    }
}

# Use the ADMIN JWT for POST request to Awards Service
if ($adminToken) {
    $awardsHeaders = @{ "Authorization" = "Bearer $adminToken" }
    
    # Example POST (create award)
    $awardBody = @{ 
        name = "Test Award $(Get-Random)"; 
        description = "Award for testing"; 
        pointsValue = 10;
        iconUrl = "https://example.com/icon.png"
    } | ConvertTo-Json
    
    try {
        Write-Host "Attempting to create award with admin token..." -ForegroundColor Yellow
        $awardsPostResponse = Invoke-RestMethod -Method Post -Uri "http://localhost:8089/api/v1/awards" -Headers $awardsHeaders -Body $awardBody -ContentType 'application/json'
        Write-Host "Award created successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Awards Service POST error: $_" -ForegroundColor Red
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode.value__
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd()
            Write-Host "Status code: $statusCode" -ForegroundColor Red
            Write-Host "Raw response body:" -ForegroundColor Red
            Write-Host $responseBody -ForegroundColor Red
            
            if ($statusCode -eq 403) {
                Write-Host "`nNote: 403 Forbidden error indicates JWT token doesn't contain proper role information." -ForegroundColor Yellow
                Write-Host "The auth service JWT generation needs to include user roles for proper authorization." -ForegroundColor Yellow
                Write-Host "This is a known issue - the JWT token only contains username, not role information." -ForegroundColor Yellow
            }
        } else {
            Write-Host "No response body available." -ForegroundColor Red
        }
    }
} else {
    Write-Host "Could not obtain ADMIN JWT for Awards Service tests." -ForegroundColor Red
    Write-Host "Skipping POST test due to authentication failure." -ForegroundColor Yellow
}

Write-Host "`n=== Testing Monitoring Service ===" -ForegroundColor Green
try {
    Write-Host "Fetching system metrics..." -ForegroundColor Yellow
    $metricsResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8091/actuator/metrics" `
        -Headers $headers
    Write-Host "System metrics fetched successfully" -ForegroundColor Green

    # Get health status
    $healthResponse = Invoke-RestMethod -Method Get -Uri "http://localhost:8091/actuator/health" `
        -Headers $headers
    Write-Host "Health status fetched successfully" -ForegroundColor Green
} catch {
    Write-Host "Monitoring Service error: $_" -ForegroundColor Red
}

Write-Host "`n=== All Tests Completed ===" -ForegroundColor Green 