export function sanitizeText(input: string): string {
  return input
    .trim()
    .replace(/<[^>]*>/g, '')
    .replace(/\s+/g, ' ');
}
