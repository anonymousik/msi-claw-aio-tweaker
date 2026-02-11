# Contributing to MSI Claw AIO Tweaker

Thank you for your interest in contributing to MSI Claw AIO Tweaker! This document provides guidelines and instructions for contributing to the project.

**Repository:** https://anonymousik.is-a.dev/msi-claw-aio-tweaker  
**GitHub:** https://github.com/anonymousik/msi-claw-aio-tweaker  
**Maintainer:** Anonymousik (SecFERRO Division)

---

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How Can I Contribute?](#how-can-i-contribute)
3. [Development Setup](#development-setup)
4. [Coding Standards](#coding-standards)
5. [Pull Request Process](#pull-request-process)
6. [Testing Guidelines](#testing-guidelines)
7. [Documentation Guidelines](#documentation-guidelines)
8. [Security Guidelines](#security-guidelines)
9. [Community](#community)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of experience level, gender, gender identity and expression, sexual orientation, disability, personal appearance, body size, race, ethnicity, age, religion, or nationality.

### Our Standards

**Examples of behavior that contributes to a positive environment:**

✅ Using welcoming and inclusive language  
✅ Being respectful of differing viewpoints and experiences  
✅ Gracefully accepting constructive criticism  
✅ Focusing on what is best for the community  
✅ Showing empathy towards other community members  

**Examples of unacceptable behavior:**

❌ Trolling, insulting/derogatory comments, and personal or political attacks  
❌ Public or private harassment  
❌ Publishing others' private information without permission  
❌ Other conduct which could reasonably be considered inappropriate  

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting the project maintainer. All complaints will be reviewed and investigated promptly and fairly.

---

## How Can I Contribute?

### 1. Reporting Bugs

**Before Submitting a Bug Report:**

- Check the [existing issues](https://github.com/anonymousik/msi-claw-aio-tweaker/issues) to avoid duplicates
- Ensure you're using the latest version
- Try to reproduce the bug on a clean Windows installation if possible

**How to Submit a Good Bug Report:**

Include the following information:

```markdown
**Bug Description**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Run command '...'
2. Select option '...'
3. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**System Information**
- MSI Claw Model: [e.g., A1M, 8 AI+]
- CPU: [e.g., Core Ultra 7 155H]
- OS: [e.g., Windows 11 23H2 Build 22631.3007]
- BIOS Version: [e.g., E1T41IMS.109]
- Script Version: [e.g., 5.0.0]

**Logs**
Attach relevant log files from:
- `%USERPROFILE%\MSI_Claw_Logs\optimizer.log`
- `%USERPROFILE%\MSI_Claw_Logs\audit.log`

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Additional Context**
Any other information about the problem.
```

### 2. Suggesting Enhancements

**Before Submitting an Enhancement:**

- Check if the feature already exists
- Check the [roadmap](CHANGELOG.md#upcoming-releases) for planned features
- Search existing issues for similar suggestions

**How to Submit a Good Enhancement Suggestion:**

```markdown
**Feature Description**
A clear and concise description of the enhancement.

**Problem Statement**
What problem does this solve? What use case does it address?

**Proposed Solution**
How should this work? What should the user experience be?

**Alternatives Considered**
What other solutions have you considered?

**Implementation Details** (optional)
Technical details about how this could be implemented.

**Additional Context**
Any other information, mockups, or examples.
```

### 3. Contributing Code

We welcome code contributions! Here's how to get started:

#### **Types of Contributions:**

- 🐛 **Bug Fixes** - Fix reported issues
- ✨ **New Features** - Implement enhancements from the roadmap
- 📚 **Documentation** - Improve docs, add examples, fix typos
- 🧪 **Tests** - Add or improve test coverage
- 🔒 **Security** - Address security vulnerabilities
- ♻️ **Refactoring** - Improve code quality without changing behavior

---

## Development Setup

### Prerequisites

**Required:**
- Windows 10 20H1+ or Windows 11
- PowerShell 5.1+ (check: `$PSVersionTable.PSVersion`)
- Git for Windows
- Administrator privileges
- MSI Claw hardware (or virtual machine for testing)

**Recommended:**
- Visual Studio Code with PowerShell extension
- Pester 5.0+ (testing framework)
- PSScriptAnalyzer (linting)

### Initial Setup

1. **Fork the Repository**
   ```bash
   # On GitHub, click "Fork" button
   ```

2. **Clone Your Fork**
   ```powershell
   git clone https://github.com/YOUR_USERNAME/msi-claw-aio-tweaker.git
   cd msi-claw-aio-tweaker
   ```

3. **Add Upstream Remote**
   ```powershell
   git remote add upstream https://github.com/anonymousik/msi-claw-aio-tweaker.git
   ```

4. **Install Development Dependencies**
   ```powershell
   # Install Pester (testing framework)
   Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
   
   # Install PSScriptAnalyzer (linting)
   Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser
   ```

5. **Create a Development Branch**
   ```powershell
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

---

## Coding Standards

### PowerShell Style Guide

#### **1. Naming Conventions**

```powershell
# ✅ GOOD: Use approved PowerShell verbs
function Get-SystemInfo { }
function Set-PowerPlan { }
function Test-Compatibility { }
function Start-Optimization { }

# ❌ BAD: Unapproved verbs
function Fetch-SystemInfo { }      # Use Get-
function Change-PowerPlan { }      # Use Set-
function Check-Compatibility { }    # Use Test-
function Run-Optimization { }      # Use Start-
```

**Approved Verb List:**
- **Get** - Retrieve data
- **Set** - Modify data
- **Test** - Verify condition
- **Start** - Begin operation
- **Stop** - End operation
- **New** - Create object
- **Remove** - Delete object
- **Invoke** - Execute action

See full list: `Get-Verb`

#### **2. Function Structure**

```powershell
function Verb-Noun {
    <#
    .SYNOPSIS
        Brief description (one sentence)
    
    .DESCRIPTION
        Detailed description of what the function does
    
    .PARAMETER ParameterName
        Description of the parameter
    
    .EXAMPLE
        Verb-Noun -ParameterName "Value"
        Description of what this example does
    
    .OUTPUTS
        [Type] Description of output
    
    .NOTES
        Additional information
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RequiredParam,
        
        [Parameter(Mandatory = $false)]
        [switch]$OptionalSwitch
    )
    
    # Function body
    try {
        # Main logic
        Write-Verbose "Doing something with $RequiredParam"
        
        # Return result
        return $result
    }
    catch {
        Write-Error "Error in Verb-Noun: $_"
        throw
    }
}
```

#### **3. Security Best Practices**

```powershell
# ✅ GOOD: Use Start-Process instead of Invoke-Expression
$args = @('/command', 'arg1', 'arg2')
$process = Start-Process -FilePath 'executable.exe' -ArgumentList $args -NoNewWindow -Wait -PassThru

# ❌ BAD: Never use Invoke-Expression
Invoke-Expression "executable.exe /command arg1 arg2"  # SECURITY VULNERABILITY!

# ✅ GOOD: Validate and sanitize user input
function Read-HostSanitized {
    param([ValidateSet('AlphaNumeric', 'FilePath', 'Email')]$Mode)
    # ... sanitization logic
}

# ❌ BAD: Direct use of user input
$userInput = Read-Host "Enter path"
Set-Location $userInput  # INJECTION RISK!

# ✅ GOOD: Verify file integrity
$expectedHash = "ABC123..."
$actualHash = (Get-FileHash -Path $file -Algorithm SHA256).Hash
if ($actualHash -ne $expectedHash) {
    throw "File integrity check failed!"
}

# ❌ BAD: No verification
Invoke-WebRequest -Uri $url -OutFile $file
Import-Module $file  # Could be compromised!
```

#### **4. Error Handling**

```powershell
# ✅ GOOD: Comprehensive error handling
try {
    $result = Get-SomeData -ErrorAction Stop
    
    if (-not $result) {
        throw "No data returned"
    }
    
    # Process result
    return $result
}
catch {
    Write-Error "Failed to get data: $_"
    Write-Log -Level Error -Message "Exception: $($_.Exception.Message)"
    throw
}
finally {
    # Cleanup
    if ($resource) {
        $resource.Dispose()
    }
}

# ❌ BAD: Silent failures
$result = Get-SomeData -ErrorAction SilentlyContinue
# No error checking, just hope it worked
```

#### **5. Logging**

```powershell
# ✅ GOOD: Use centralized logging
Write-Log -Level Info -Message "Starting optimization"
Write-Log -Level Warning -Message "BIOS version outdated"
Write-Log -Level Error -Message "Failed to apply setting" -Exception $_

# ✅ GOOD: Audit logging for security events
Write-AuditLog -Action "ConfigurationChange" -Details @{
    Setting = "MemoryIntegrity"
    OldValue = "Enabled"
    NewValue = "Disabled"
    User = $env:USERNAME
}

# ❌ BAD: Ad-hoc logging
Write-Host "Something happened"  # No persistence, not structured
```

#### **6. Comments and Documentation**

```powershell
# ✅ GOOD: Meaningful comments explaining WHY, not WHAT
# Disable Memory Integrity because it causes 15-25% FPS degradation
# on Intel Arc GPUs due to Hyper-V overhead
Set-ItemProperty -Path $regPath -Name 'Enabled' -Value 0

# ❌ BAD: Obvious comments explaining WHAT
# Set the Enabled property to 0
Set-ItemProperty -Path $regPath -Name 'Enabled' -Value 0

# ✅ GOOD: Complex logic explained
# The ASPM (Active State Power Management) setting uses:
# 0 = Disabled (max performance, +5-8% GPU on AC power)
# 1 = Moderate (balanced)
# 2 = Aggressive (max power saving)
$asPmValue = if ($OnBattery) { 1 } else { 0 }

# ✅ GOOD: TODO comments with context
# TODO: Add support for custom TDP limits (requires MSI Center M integration)
# See issue #42: https://github.com/anonymousik/msi-claw-aio-tweaker/issues/42
```

---

## Pull Request Process

### 1. Before Submitting

**Checklist:**

- [ ] Code follows PowerShell style guide
- [ ] All functions have proper documentation (`.SYNOPSIS`, `.DESCRIPTION`, etc.)
- [ ] Security best practices followed (no Invoke-Expression, input validation, etc.)
- [ ] Logging added for important operations
- [ ] Error handling implemented
- [ ] Tests added/updated (when applicable)
- [ ] Documentation updated (README, INSTALLATION, etc.)
- [ ] Tested on clean Windows installation
- [ ] No breaking changes (or clearly documented if unavoidable)

### 2. Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding/updating tests
- `chore:` Maintenance tasks

**Examples:**

```
feat(optimization): add custom TDP profile support

Added ability to create custom TDP profiles with user-defined
wattage limits. Profiles are stored in config.json and can be
applied via Set-PerformanceProfile.

Closes #42
```

```
fix(diagnostics): correct BIOS version detection for Claw 8 AI+

BIOS version regex was not matching Lunar Lake BIOS format.
Updated pattern to support both Meteor Lake and Lunar Lake.

Fixes #58
```

```
docs(readme): update installation instructions

Added troubleshooting section for Windows Defender false positives.
Clarified PowerShell execution policy requirements.
```

### 3. Pull Request Template

```markdown
## Description
<!-- Describe your changes in detail -->

## Motivation and Context
<!-- Why is this change required? What problem does it solve? -->
<!-- If it fixes an open issue, please link to the issue here. -->

## How Has This Been Tested?
<!-- Describe how you tested your changes -->
- [ ] Tested on MSI Claw A1M (Core Ultra 7 155H)
- [ ] Tested on MSI Claw 8 AI+ (Lunar Lake)
- [ ] Tested on clean Windows 11 installation
- [ ] Tested all affected functions manually
- [ ] Added automated tests (if applicable)

## Types of Changes
<!-- What types of changes does your code introduce? Put an `x` in all the boxes that apply: -->
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update

## Checklist:
- [ ] My code follows the PowerShell style guide
- [ ] I have added/updated documentation
- [ ] I have added/updated tests (if applicable)
- [ ] All new and existing tests passed
- [ ] I have updated the CHANGELOG.md
- [ ] My changes don't introduce any security vulnerabilities
- [ ] I have tested my changes on actual MSI Claw hardware
```

### 4. Review Process

1. **Automated Checks**
   - PSScriptAnalyzer (linting)
   - Pester tests (if CI/CD enabled)
   - Security scan
   
2. **Manual Review**
   - Code quality review by maintainer
   - Security review for sensitive changes
   - Testing on MSI Claw hardware (if applicable)
   
3. **Feedback**
   - Address review comments
   - Update PR as needed
   - Re-request review
   
4. **Merge**
   - PR approved by maintainer
   - All checks passed
   - Merged to `main` branch

---

## Testing Guidelines

### Unit Testing with Pester

```powershell
# Example: Test for Set-HibernationConfiguration function

Describe 'Set-HibernationConfiguration' {
    Context 'When hibernation is disabled' {
        It 'Should enable hibernation' {
            # Arrange
            Mock Get-Command { $true }  # powercfg available
            Mock Start-Process { @{ ExitCode = 0 } }
            
            # Act
            $result = Set-HibernationConfiguration
            
            # Assert
            $result.Success | Should -Be $true
            $result.Changes | Should -Contain 'Hibernation enabled'
        }
    }
    
    Context 'When powercfg fails' {
        It 'Should handle error gracefully' {
            # Arrange
            Mock Start-Process { @{ ExitCode = 1 } }
            
            # Act
            $result = Set-HibernationConfiguration
            
            # Assert
            $result.Success | Should -Be $false
            $result.Errors.Count | Should -BeGreaterThan 0
        }
    }
}
```

### Integration Testing

```powershell
# Example: Test full optimization workflow

Describe 'Full Optimization Workflow' {
    It 'Should complete without errors on clean system' {
        # This requires actual MSI Claw hardware or VM
        
        # Arrange
        $backupId = New-SystemBackup -Description "Pre-test backup"
        
        # Act
        $result = Start-FullOptimization -Mode Automatic
        
        # Assert
        $result.OverallSuccess | Should -Be $true
        
        # Cleanup
        Restore-SystemBackup -BackupId $backupId -Force
    }
}
```

### Test Coverage Goals

- **Minimum:** 50% code coverage
- **Target:** 70% code coverage
- **Critical functions:** 90%+ coverage (security, backup, diagnostics)

---

## Documentation Guidelines

### Where to Document

- **README.md** - Project overview, quick start
- **INSTALLATION.md** - Detailed installation, troubleshooting
- **QUICK_START.md** - Fast setup guide
- **WIKI.md** - In-depth technical documentation
- **Code Comments** - Inline documentation for complex logic
- **Function Documentation** - `.SYNOPSIS`, `.DESCRIPTION`, `.EXAMPLE` blocks

### Documentation Standards

```powershell
<#
.SYNOPSIS
    Brief one-line description

.DESCRIPTION
    Detailed description explaining:
    - What the function does
    - Why it's needed
    - How it works (at a high level)
    - Any important considerations

.PARAMETER ParameterName
    What this parameter does
    Valid values and their meanings

.EXAMPLE
    Actual-FunctionName -Parameter "Value"
    
    Description of what this example demonstrates

.EXAMPLE
    Actual-FunctionName -Parameter "Value" -AnotherParam
    
    Description of this more complex example

.OUTPUTS
    [Type] Description of what is returned

.NOTES
    Author: Anonymousik (SecFERRO Division)
    Version: 5.0.0
    Last Modified: 2026-02-11
    
    Additional notes about:
    - Compatibility requirements
    - Performance considerations
    - Security implications
#>
```

---

## Security Guidelines

### Security-First Development

1. **Never Use Invoke-Expression**
   - Use `Start-Process` with argument arrays
   - Prevents command injection attacks

2. **Always Validate Input**
   - Use `[ValidateSet()]` for enums
   - Use `Read-HostSanitized` for user input
   - Check file paths before use

3. **Verify Downloads**
   - Always use HTTPS
   - Verify SHA256 hashes
   - Optional: Check digital signatures

4. **Audit Logging**
   - Log all security-relevant events
   - Log configuration changes
   - Log privilege escalations

5. **Least Privilege**
   - Only elevate when necessary
   - Drop privileges after sensitive operations
   - Document why elevation is needed

### Reporting Security Vulnerabilities

**DO NOT** open a public issue for security vulnerabilities.

Instead, email: [security details to be added]

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

See [SECURITY.md](SECURITY.md) for full policy.

---

## Community

### Where to Get Help

- **GitHub Issues:** https://github.com/anonymousik/msi-claw-aio-tweaker/issues
- **Reddit:** r/MSIClaw
- **Discord:** [Link to be added]

### Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Credited in release notes
- Added to CONTRIBUTORS.md (if significant contribution)

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## Thank You!

Your contributions make MSI Claw AIO Tweaker better for everyone. We appreciate your time and effort! 🎉

**Questions?** Open an issue or reach out to the maintainer.

---

**Maintainer:** Anonymousik (SecFERRO Division)  
**Repository:** https://anonymousik.is-a.dev/msi-claw-aio-tweaker  
**Last Updated:** 2026-02-11
