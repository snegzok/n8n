#!/bin/bash
# scripts/set-grafana-domain.sh - Меняет домен в Grafana/Prometheus стеке

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRAFANA_FILE="$PROJECT_ROOT/grafana-prometheus/prometheus-stack.yaml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

detect_current_domain() {
    if [ ! -f "$GRAFANA_FILE" ]; then
        echo -e "${RED}❌ File not found${NC}"
        exit 1
    fi
    
    # Ищем в строке traefik.http.routers.grafana.rule
    local domain=$(grep -oP "Host\(\`\K[^\`]+" "$GRAFANA_FILE" 2>/dev/null | head -1)
    
    if [ -z "$domain" ]; then
        domain=$(grep -oE 'GF_SERVER_ROOT_URL=https?://([^/]+)' "$GRAFANA_FILE" | sed 's/GF_SERVER_ROOT_URL=https:\/\///' | head -1)
    fi
    
    if [ -z "$domain" ]; then
        domain="grafana.expert-only.ru"
    fi
    
    echo "$domain"
}

replace_domain() {
    local old_domain="$1"
    local new_domain="$2"
    
    # Прямая замена строки с Host
    sed -i "s/Host(\`${old_domain}\`)/Host(\`${new_domain}\`)/g" "$GRAFANA_FILE"
    
    # Замена GF_SERVER_ROOT_URL
    sed -i "s|GF_SERVER_ROOT_URL=https://${old_domain}|GF_SERVER_ROOT_URL=https://${new_domain}|g" "$GRAFANA_FILE"
}

show_current() {
    echo -e "${BLUE}📋 Строка в манифесте:${NC}"
    grep "traefik.http.routers.grafana.rule" "$GRAFANA_FILE" 2>/dev/null || echo "Не найдено"
    echo ""
    
    local domain=$(detect_current_domain)
    echo -e "${GREEN}🌐 Текущий домен Grafana: ${domain}${NC}"
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
    cp "$GRAFANA_FILE" "$GRAFANA_FILE.bak"
    
    # Заменяем
    replace_domain "$current_domain" "$new_domain"
    
    echo ""
    echo -e "${GREEN}✅ Домен изменён на: ${new_domain}${NC}"
    echo ""
    echo -e "${BLUE}📌 Проверьте:${NC}"
    grep "traefik.http.routers.grafana.rule" "$GRAFANA_FILE"
}

case "${1:-}" in
    -h|--help)
        cat << EOF
${BLUE}📖 Использование:${NC}
  ./scripts/set-grafana-domain.sh [НОВЫЙ_ДОМЕН]

${BLUE}📝 Примеры:${NC}
  ./scripts/set-grafana-domain.sh --show
  ./scripts/set-grafana-domain.sh grafana.mycompany.ru
EOF
        ;;
    --show)
        show_current
        ;;
    *)
        if [ -z "$1" ]; then
            echo "❌ Укажите домен"
            exit 1
        fi
        set_domain "$1"
        ;;
esac
