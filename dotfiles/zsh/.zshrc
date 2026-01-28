# Zsh Configuration

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting)

# Source Catppuccin syntax highlighting BEFORE Oh My Zsh loads the plugin
[[ -f ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh ]] && \
    source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh

# Load Oh My Zsh
[[ -f $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

# Source shared shell configs
for config in ~/.shellrc.d/*(N); do
    [[ -f "$config" ]] && source "$config"
done

# Source zsh-specific configs
for config in ~/.zshrc.d/*(N); do
    [[ -f "$config" ]] && source "$config"
done
