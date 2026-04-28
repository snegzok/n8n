#!/bin/bash
# scripts/set-n8n-domain.sh - Меняет домен в n8n стеке

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
N8N_FILE="$PROJECT_ROOT/n8n/n8n-stack.yml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функция определения текущего домена
detect_current_domain() {
    if [ ! -f "$N8N_FILE" ]; then
        echo -e "${RED}❌ File not found${NC}"
        exit 1
    fi
    
    # Ищем домен в строке traefik.http.routers.n8n.rule
    local domain=$(grep -oP "Host\(\`\K[^\`]+" "$N8N_FILE" 2>/dev/null | head -1)
    
    # Если не нашли, ищем в WEBHOOK_URL
    if [ -z "$domain" ]; then
        domain=$(grep -oE 'WEBHOOK_URL: https?://([^/]+)' "$N8N_FILE" | sed 's/WEBHOOK_URL: https:\/\///' | head -1)
    fi
    
    if [ -z "$domain" ]; then
        domain="expert-only.ru"
    fi
    
    echo "$domain"
}

# Функция замены домена (точная)
replace_domain() {
    local old_domain="$1"
    local new_domain="$2"
    
    # Экранируем точки
    local old_escaped=$(echo "$old_domain" | sed 's/\./\\./g')
    
    # Заменяем строку Host(`old`) на Host(`new`)
    sed -i "s/Host(\`${old_escaped}\`)/Host(\`${new_domain}\`)/g" "$N8N_FILE"
    
    # Заменяем WEBHOOK_URL
    sed -i "s|WEBHOOK_URL: https://${old_escaped}|WEBHOOK_URL: https://${new_domain}|g" "$N8N_FILE"
    
    # Заменяем N8N_HOST
    sed -i "s|N8N_HOST=${old_escaped}|N8N_HOST=${new_domain}|g" "$N8N_FILE"
}

show_help() {
    cat << EOF
${BLUE}📖 Использование:${NC}
  ./scripts/set-n8n-domain.sh [НОВЫЙ_ДОМЕН] [ОПЦИИ]

${BLUE}📝 Примеры:${NC}
  ./scripts/set-n8n-domain.sh --show
  ./scripts/set-n8n-domain.sh n8n.mycompany.ru
EOF
}

show_current() {
    local domain=$(detect_current_domain)
    echo -e "${GREEN}🌐 Текущий домен n8n: ${domain}${NC}"
    
    # Показываем строку с Host
    echo ""
    echo -e "${BLUE}📋 Строка в манифесте:${NC}"
    grep "traefik.http.routers.n8n.rule" "$N8N_FILE" || echo "Не найдено"
}

set_domain() {
    local new_domain="$1"
    local current_domain=$(detect_current_domain)
    
    echo -e "${BLUE}🔍 Текущий домен: ${current_domain}${NC}"
    echo -e "${GREEN}🚀 Новый домен:   ${new_domain}${NC}"
    echo ""
    
    if [ "$current_domain" = "$new_domain" ]; then
        echo -e "${YELLOW}⚠️  Домен уже установлен${NC}"
        exit 0
    fi
    
    # Бэкап
    cp "$N8N_FILE" "$N8N_FILE.bak"
    
    # Заменяем
    replace_domain "$current_domain" "$new_domain"
    
    echo ""
    echo -e "${GREEN}✅ Домен изменён на: ${new_domain}${NC}"
    echo ""
    echo -e "${BLUE}📌 Проверьте изменения:${NC}"
    echo "  grep 'traefik.http.routers.n8n.rule' $N8N_FILE"
}

case "${1:-}" in
    -h|--help)
        show_help
        ;;
    -s|--show)
        show_current
        ;;
    *)
        if [ -z "$1" ]; then
            show_help
            exit 1
        fi
        set_domain "$1"
        ;;
esac
