# Release Checklist

## Initial Setup

### RubyGems Configuration

#### Option 1: Credentials File (Recommended)
1. Create/edit `~/.gem/credentials`:
   ```yaml
   ---
   :rubygems_api_key: your_api_key_here
   ```
2. Set proper permissions:
    ```bash
    chmod 600 ~/.gem/credentials
    ```

#### Option 2: Environment Variable
Set `RUBYGEMS_API_KEY` environment variable:
```bash
export RUBYGEMS_API_KEY=your_api_key_here
```

### First-time Push with MFA
1. Get your MFA code ready
2. Push the gem:
```bash
gem push pkg/obfuscator-rb-X.Y.Z.gem --otp YOUR_MFA_CODE
```

### Common RubyGems CLI commands
```bash
# Build gem with the gemspec file
gem build obfuscator-rb.gemspec # output: obfuscator-rb-X.Y.Z.gem

# Build gem with the Rakefile
rake build # output: pkg/obfuscator-rb-X.Y.Z.gem

# Push a new version of the gem
gem push pkg/obfuscator-rb-X.Y.Z.gem --otp YOUR_MFA_CODE

# Yank a version of the gem
gem yank obfuscator-rb -v X.Y.Z --otp YOUR_MFA_CODE

# List owned gems
gem list -r obfuscator-rb

# Check gem details
gem info obfuscator-rb

# Install a specific version of the gem locally
gem install ./obfuscator-rb-X.Y.Z.gem
```

## Pre-release Checks

### 1. Code Quality
- [ ] Run full test suite:
  ```bash
  bundle exec rake test
  ```
- [ ] Run Rubocop:
  ```bash
  bundle exec rubocop
  ```

### 2. Version Update
- [ ] Update version in `lib/obfuscator/version.rb`
- [ ] Update CHANGELOG.md
  - Add new version section
  - Document all changes under appropriate categories
  - Add release date

### 3. Local Build & Test
- [ ] Build gem using Rake (preferred):
  ```bash
  bundle exec rake build
  # Gem will be in pkg/obfuscator-rb-X.Y.Z.gem
  ```
  OR build directly:
  ```bash
  gem build obfuscator-rb.gemspec
  ```
- [ ] Install and test locally:
  ```bash
  gem install pkg/obfuscator-rb-X.Y.Z.gem
  # OR if built directly:
  # gem install ./obfuscator-rb-X.Y.Z.gem
  ```
- [ ] Verify in IRB:
  ```ruby
  require 'obfuscator-rb'
  # Test basic functionality
  ```

### 4. Documentation Check
- [ ] Review gemspec
  - Version number
  - Dependencies
  - Metadata
- [ ] Check README is up to date
- [ ] Verify YARD documentation if changed

## Release Process

### 5. Version Control
- [ ] Commit changes:
  ```bash
  git add .
  git commit -m "feat: release X.Y.Z"
  ```
- [ ] Create version tag:
  ```bash
  git tag -a vX.Y.Z -m "Release X.Y.Z"
  ```
- [ ] Push changes and tags:
  ```bash
  git push origin master
  git push origin vX.Y.Z
  ```

### 6. Publish
- [ ] Push to RubyGems:
  ```bash
  gem push pkg/obfuscator-rb-X.Y.Z.gem --otp YOUR_MFA_CODE
  ```
- [ ] Verify gem page on RubyGems.org

## Post-release
- [ ] Clean up local gem files:
  ```bash
  rm -rf pkg/
  # OR if built directly:
  # rm obfuscator-rb-*.gem
  ```
- [ ] Announce release if significant
- [ ] Update any related documentation or wiki pages

# Git Workflow Guide

## Branch Structure
- `master`: Release branch, contains only tagged releases
- `dev`: Main development branch (local only)
- Feature branches: Created from and merged back to `dev`

## Regular Development Flow
1. Start work from dev:
```bash
git checkout dev
git pull origin master  # sync with latest release if needed
git checkout -b feat/my-feature
```

2. Make changes and commit:
```bash
git add .
git commit -m "feat: description"
```

3. Merge back to dev:
```bash
git checkout dev
git merge feat/my-feature
git branch -d feat/my-feature
```

## Release Process
1. Prepare release in dev:
```bash
git checkout dev
# Update version and CHANGELOG
git commit -m "chore: prepare release X.Y.Z"
```

2. Create release:
```bash
git checkout master
git merge --squash dev  # squash all dev commits
git commit -m "release: version X.Y.Z"
git tag -a vX.Y.Z -m "version X.Y.Z"
```

3. Push release:
```bash
git push origin master --tags
```

4. Update dev:
```bash
git checkout dev
git merge master  # keep dev in sync with latest release
``` 